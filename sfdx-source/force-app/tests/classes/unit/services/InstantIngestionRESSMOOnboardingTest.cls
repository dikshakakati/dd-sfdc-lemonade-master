/**
 * @description       : InstantIngestionOnboardingServiceImpl  RESSMO testMethods.
 * @author            : VenkateshDD
 * @group             : DDMx RESSMO - Aethereus
 * @last modified on  : 12-06-2024
 * @last modified by  : Soumya Dash
 **/
@IsTest
public class InstantIngestionRESSMOOnboardingTest {

    /**
     *  Begin - Test class to execute if one of these classes is updated.
     */
    private static final List<System.Type> CLASS_REFERENCE = new List<System.Type>{
        InstantIngestionOnboardingServiceImpl.class
    };

    private static final String VERTICAL_RX = 'Rx';
    private static final String STATIC_RESOURCE_TEST_JSON = 'Inbound_Ingestion_Payload_Data';
    private static final String ONBOARDING_SOURCE = 'RESSMO';
    private static final String ONBOARDING_EVENT = 'Onboarding Event';
    private static final String UNIQUE_IDENTIFER = '92108a53-e8d9-4a0c-9193-9152aeb86fe4';
    private static final String BUSINESS_ID = '12820285';
    private static final String BUSINESS_GROUP_ID = '128';
    private static final String STORE_ID = '28040568';
    private static final String BUSINESS_ACCOUNT_NAME = 'Los Pinchos de mi Abuela';
    private static final String CURRENCY_ISO_CODE_USD = 'USD';
    private static final String SUCESS_STATUS = 'Success';
    private static final String SUBMARKET_ID = '591';
    private static final String SUBMARKET_NAME = 'Kennewick';
    private static final String PENDING_STATUS = 'Pending';
    private static final String EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED_RESSMO = 'EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED_RESSMO';
    private static final String EVENT_TOPIC_ACCOUNT_RECORD_UPDATE_BY_INGESTION_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_ACCOUNT_RECORD_UPDATE_BY_INGESTION_ONBOARDING_PAYLOAD';
    private static final String MENU_UI_TYPE_RESTAURANT = 'Restaurant';
    private static final String TABLET = 'Tablet (DoorDash Owns)';
    private static final String INACTIVE_REASON_SUBMITTED = 'Submitted';
    private static final String STATUS_INACTIVE = 'Inactive';

    private static final Id BUSNINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Business')
        .getRecordTypeId();
    private static final Id STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Store')
        .getRecordTypeId();

    @IsTest
    static void testWhenRESSMONetNewStoreOnboardingThenInitiateFullServeAccountProcess() {
        Id mockBusinessVerticalId = Fake.generateId(Business_Vertical__c.class);
        Id storeAccountId = Fake.generateId(Account.class);
        Id businessAccountId = Fake.generateId(Account.class);
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id bizRefId = Fake.generateId(Business_Reference__c.class);
        Id mockBrandId = Fake.generateId(Brand__c.class);

        Brand_Association__c mockBrandAssc = new Brand_Association__c(
            Brand_Name__c = mockBrandId,
            Business_Account_Name__c = businessAccountId
        );

        Business_Reference__c bizref = new Business_Reference__c(
            Id = bizRefId,
            Unique_Identifier__c = UNIQUE_IDENTIFER,
            Brand__c = mockBrandId,
            Business_Name__c = BUSINESS_ACCOUNT_NAME,
            Business_Vertical__c = mockBusinessVerticalId,
            External_Id__c = BUSINESS_ID,
            Business_Group_Id__c = BUSINESS_GROUP_ID
        );

        Business_Vertical__c businessVerticalRx = new Business_Vertical__c(
            Id = mockBusinessVerticalId,
            Name = VERTICAL_RX
        );

        Fake fakeStoreAccount = new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.RecordTypeId, STORE_RECORD_TYPE_ID)
            .setField(Account.Unique_Identifier__c, UNIQUE_IDENTIFER)
            .setField(Account.ParentId, businessAccountId)
            .setField(Account.CurrencyIsoCode, CURRENCY_ISO_CODE_USD)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setParent(
                'Parent',
                new Fake(Account.class)
                    .setField(Account.Id, businessAccountId)
                    .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
                    .setField(Account.RecordTypeId, BUSNINESS_RECORD_TYPE_ID)
                    .setField(Account.CurrencyIsoCode, CURRENCY_ISO_CODE_USD)
            );
        Account storeAccount = (Account) fakeStoreAccount.toSObject();

        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        InstantIngestionPayloadParser payload = (InstantIngestionPayloadParser) System.JSON.deserialize(
            payloadString,
            InstantIngestionPayloadParser.class
        );
        payload.onboardingSource = ONBOARDING_SOURCE;
        payload.store.storeAccountId = storeAccountId;
        payload.store.isAdditionalStore = false;

        Inbound_Ingestion_Log__c inboundIngestionLog = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            UUID__c = UNIQUE_IDENTIFER,
            Payload__c = JSON.serialize(payload),
            Integration_Type__c = ONBOARDING_EVENT
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IInstantIngestionRecordsGetterService mockIInstantIngestionRecordGetterService = (IInstantIngestionRecordsGetterService) mocks.mock(
            IInstantIngestionRecordsGetterService.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IBrandAssociationsSelector mockBrandAssociationsSelector = (IBrandAssociationsSelector) mocks.mock(
            IBrandAssociationsSelector.class
        );
        IBusinessReferencesSelector mockBusinessReferenceSelector = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IInboundIngestionLogsSelector mockInboundIngestionSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );

        mocks.startStubbing();

        mocks.when(mockIInstantIngestionRecordGetterService.getRxBusinessVertical())
            .thenReturn(businessVerticalRx);
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectStoreAccountByUUIDWithXrefs(
                    new Set<String>{ UNIQUE_IDENTIFER }
                )
            )
            .thenReturn(new List<Account>{ storeAccount });

        mocks.when(mockBrandAssociationsSelector.sObjectType())
            .thenReturn(Brand_Association__c.SObjectType);
        mocks.when(
                mockBrandAssociationsSelector.selectByBusinessAccountIds(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(new List<Brand_Association__c>{ mockBrandAssc });

        mocks.when(mockBusinessReferenceSelector.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                mockBusinessReferenceSelector.selectByBusinessVerticalsBrandIdsAndCurrencyISOCodes(
                    new Set<Id>{ mockBusinessVerticalId },
                    new Set<Id>{ mockBrandId },
                    new Set<String>{ CURRENCY_ISO_CODE_USD }
                )
            )
            .thenReturn(new List<Business_Reference__c>{ bizref });

        mocks.when(mockInboundIngestionSelector.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(
                mockInboundIngestionSelector.selectById(new Set<Id>{ mockInboundingestionlogId })
            )
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ inboundIngestionLog });

        mocks.stopStubbing();

        Application.SERVICE.setMock(
            IInstantIngestionRecordsGetterService.class,
            mockIInstantIngestionRecordGetterService
        );
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockBrandAssociationsSelector);
        Application.SELECTOR.setMock(mockBusinessReferenceSelector);
        Application.SELECTOR.setMock(mockInboundIngestionSelector);
        Application.UNITOFWORK.setMock(mockUOW);

        Instant_Ingestor__e mockInstantIngestorEvent = new Instant_Ingestor__e(
            Payload__c = JSON.serialize(new Set<Id>{ mockInboundingestionlogId }),
            Topic__c = EVENT_TOPIC_ACCOUNT_RECORD_UPDATE_BY_INGESTION_ONBOARDING_PAYLOAD
        );
        InstantIngestionOnboardingService.execute(
            new List<Instant_Ingestor__e>{ mockInstantIngestorEvent }
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 6)).commitWork();
        Assert.areEqual(BUSINESS_ID, bizref.External_ID__c, 'Business Id should be updated');
        Assert.areEqual(BUSINESS_GROUP_ID, bizref.Business_Group_Id__c, 'Business Group Id should be updated');
    }

    @IsTest
    static void testWhenRESSMONetNewStoreOnboardingThenInitiateFullServeAccountProcessWithBizRef() {
        Id mockBusinessVerticalId = Fake.generateId(Business_Vertical__c.class);
        Id storeAccountId = Fake.generateId(Account.class);
        Id businessAccountId = Fake.generateId(Account.class);
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id bizRefId = Fake.generateId(Business_Reference__c.class);
        Id mockBrandId = Fake.generateId(Brand__c.class);

        Brand_Association__c mockBrandAssc = new Brand_Association__c(
            Brand_Name__c = mockBrandId,
            Business_Account_Name__c = businessAccountId
        );

        Business_Reference__c bizref = new Business_Reference__c(
            Id = bizRefId,
            Unique_Identifier__c = UNIQUE_IDENTIFER,
            Brand__c = mockBrandId,
            Business_Name__c = BUSINESS_ACCOUNT_NAME,
            Business_Vertical__c = mockBusinessVerticalId,
            External_Id__c = BUSINESS_ID
        );

        Business_Vertical__c businessVerticalRx = new Business_Vertical__c(
            Id = mockBusinessVerticalId,
            Name = VERTICAL_RX
        );

        Fake fakeStoreAccount = new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.RecordTypeId, STORE_RECORD_TYPE_ID)
            .setField(Account.Unique_Identifier__c, UNIQUE_IDENTIFER)
            .setField(Account.ParentId, businessAccountId)
            .setField(Account.CurrencyIsoCode, CURRENCY_ISO_CODE_USD)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setParent(
                'Parent',
                new Fake(Account.class)
                    .setField(Account.Id, businessAccountId)
                    .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
                    .setField(Account.RecordTypeId, BUSNINESS_RECORD_TYPE_ID)
                    .setField(Account.CurrencyIsoCode, CURRENCY_ISO_CODE_USD)
            );
        Account storeAccount = (Account) fakeStoreAccount.toSObject();

        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        InstantIngestionPayloadParser payload = (InstantIngestionPayloadParser) System.JSON.deserialize(
            payloadString,
            InstantIngestionPayloadParser.class
        );
        payload.onboardingSource = ONBOARDING_SOURCE;
        payload.store.storeAccountId = storeAccountId;
        payload.store.isAdditionalStore = false;

        Inbound_Ingestion_Log__c inboundIngestionLog = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            UUID__c = UNIQUE_IDENTIFER,
            Payload__c = JSON.serialize(payload),
            Integration_Type__c = ONBOARDING_EVENT
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IInstantIngestionRecordsGetterService mockIInstantIngestionRecordGetterService = (IInstantIngestionRecordsGetterService) mocks.mock(
            IInstantIngestionRecordsGetterService.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IBrandAssociationsSelector mockBrandAssociationsSelector = (IBrandAssociationsSelector) mocks.mock(
            IBrandAssociationsSelector.class
        );
        IBusinessReferencesSelector mockBusinessReferenceSelector = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IInboundIngestionLogsSelector mockInboundIngestionSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );

        mocks.startStubbing();

        mocks.when(mockIInstantIngestionRecordGetterService.getRxBusinessVertical())
            .thenReturn(businessVerticalRx);
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectStoreAccountByUUIDWithXrefs(
                    new Set<String>{ UNIQUE_IDENTIFER }
                )
            )
            .thenReturn(new List<Account>{ storeAccount });

        mocks.when(mockBrandAssociationsSelector.sObjectType())
            .thenReturn(Brand_Association__c.SObjectType);
        mocks.when(
                mockBrandAssociationsSelector.selectByBusinessAccountIds(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(new List<Brand_Association__c>{ mockBrandAssc });

        mocks.when(mockBusinessReferenceSelector.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                mockBusinessReferenceSelector.selectByBusinessVerticalsBrandIdsAndCurrencyISOCodes(
                    new Set<Id>{ mockBusinessVerticalId },
                    new Set<Id>{ mockBrandId },
                    new Set<String>{ CURRENCY_ISO_CODE_USD }
                )
            )
            .thenReturn(new List<Business_Reference__c>());

        mocks.when(mockInboundIngestionSelector.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(
                mockInboundIngestionSelector.selectById(new Set<Id>{ mockInboundingestionlogId })
            )
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ inboundIngestionLog });

        mocks.stopStubbing();

        Application.SERVICE.setMock(
            IInstantIngestionRecordsGetterService.class,
            mockIInstantIngestionRecordGetterService
        );
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockBrandAssociationsSelector);
        Application.SELECTOR.setMock(mockBusinessReferenceSelector);
        Application.SELECTOR.setMock(mockInboundIngestionSelector);
        Application.UNITOFWORK.setMock(mockUOW);

        Instant_Ingestor__e mockInstantIngestorEvent = new Instant_Ingestor__e(
            Payload__c = JSON.serialize(new Set<Id>{ mockInboundingestionlogId }),
            Topic__c = EVENT_TOPIC_ACCOUNT_RECORD_UPDATE_BY_INGESTION_ONBOARDING_PAYLOAD
        );
        InstantIngestionOnboardingService.execute(
            new List<Instant_Ingestor__e>{ mockInstantIngestorEvent }
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 7)).commitWork();
        Assert.areEqual(BUSINESS_ID, bizref.External_ID__c, 'Business Id should be updated');
        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW,1)).registerDirty(fflib_Match.sObjectWith(
                new Map<SObjectField, Object>{
                    Account.Id => payload.store.storeAccountId,
                    Account.Menu_UI_Type__c => MENU_UI_TYPE_RESTAURANT
                }));

       ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW,1)).registerDirty(fflib_Match.sObjectWith(
                new Map<SObjectField, Object>{
                    Account.Id => payload.store.storeAccountId,
                    Account.Tablet_User_Name__c => payload.store.ipadUserName,
                    Account.Tablet_Password__c => payload.store.ipadPassword
                }));
        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW,1)).registerDirty(fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                Account.Id => payload.store.storeAccountId,
                Account.Order_Protocol__c => TABLET
            }));
    }

    @IsTest
    static void testWhenRESSMONetNewQuoteEventFiredThenRelatedMxOrQuoteGetsSigned() {
        Id mockBusinessVerticalId = Fake.generateId(Business_Vertical__c.class);
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id mockFailedInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id xrefId = Fake.generateId(Xref__c.class);
        Id storeAccountId = Fake.generateId(Account.class);
        Id businessAccountId = Fake.generateId(Account.class);
        Id mockOppId = Fake.generateId(Opportunity.class);

        Mx_Onboarding_Link__c mxol = new Mx_Onboarding_Link__c();
        mxol.payload__c = '{}';
        mxol.UUID__c = UNIQUE_IDENTIFER;

        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        InstantIngestionPayloadParser payload = (InstantIngestionPayloadParser) System.JSON.deserialize(
            payloadString,
            InstantIngestionPayloadParser.class
        );
        payload.onboardingSource = ONBOARDING_SOURCE;

        Inbound_Ingestion_Log__c inboundIngestionLog = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            UUID__c = UNIQUE_IDENTIFER,
            Payload__c = payloadString,
            Integration_Type__c = ONBOARDING_EVENT,
            Source__c = ONBOARDING_SOURCE
        );
        Inbound_Ingestion_Log__c failedInboundIngestionLog = new Inbound_Ingestion_Log__c(
            Id = mockFailedInboundingestionlogId,
            UUID__c = UNIQUE_IDENTIFER,
            Payload__c = payloadString,
            Integration_Type__c = ONBOARDING_EVENT,
            Source__c = ONBOARDING_SOURCE,
            Business_Id__c = BUSINESS_ID
        );

        Business_Vertical__c businessVerticalRx = new Business_Vertical__c(
            Id = mockBusinessVerticalId,
            Name = VERTICAL_RX
        );

        Opportunity mockopp = new Opportunity(Id = mockOppId);
        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(Unique_Identifier__c = UNIQUE_IDENTIFER, SBQQ__Primary__c = true,SBQQ__Opportunity2__c = mockOppId );


        Fake fakeStoreAccount = new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.RecordTypeId, STORE_RECORD_TYPE_ID)
            .setField(Account.Unique_Identifier__c, UNIQUE_IDENTIFER)
            .setField(Account.ParentId, businessAccountId)
            .setField(Account.CurrencyIsoCode, CURRENCY_ISO_CODE_USD)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.POS_Integration_Type__c, 'adora');
        Account storeAccount = (Account) fakeStoreAccount.toSObject();

        Fake xrefFake = new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.External_ID__c, STORE_ID)
            .setParent('Salesforce_Account_Name__r', fakeStoreAccount);
        Xref__c xref = (Xref__c) xrefFake.toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IInstantIngestionRecordsGetterService mockIInstantIngestionRecordGetterService = (IInstantIngestionRecordsGetterService) mocks.mock(
            IInstantIngestionRecordsGetterService.class
        );

        IMxOnboardingLinksSelector mockMxOnboardingSelector = (IMxOnboardingLinksSelector) mocks.mock(
            IMxOnboardingLinksSelector.class
        );

        IInboundIngestionLogsSelector mockInboundIngestionSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );

        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);

        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );

        IQuotesSelector mockQuotesSelector = (IQuotesSelector) mocks.mock(IQuotesSelector.class);

        mocks.startStubbing();

        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectActiveXrefByExternalIdsAndExternalSourceMDSAndStoreRecordType(
                    new Set<String>{ STORE_ID }
                )
            )
            .thenReturn(new List<Xref__c>{ xref });

        mocks.when(mockMxOnboardingSelector.sObjectType())
            .thenReturn(Mx_Onboarding_Link__c.SObjectType);
        mocks.when(mockMxOnboardingSelector.selectByUUID(new Set<String>{ UNIQUE_IDENTIFER }))
            .thenReturn(new List<Mx_Onboarding_Link__c>{ mxol });

        mocks.when(mockIInstantIngestionRecordGetterService.getRxBusinessVertical())
            .thenReturn(businessVerticalRx);

        mocks.when(mockQuotesSelector.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(
                mockQuotesSelector.selectQuotesbyUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFER }
                )
            )
            .thenReturn(new List<SBQQ__Quote__c>{ mockQuote });

        mocks.when(mockInboundIngestionSelector.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(
                mockInboundIngestionSelector.selectById(new Set<Id>{ mockInboundingestionlogId })
            )
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ inboundIngestionLog });
        mocks.when(
                mockInboundIngestionSelector.selectFailedIngestionLogsByBizIds(
                    new Set<String>{ BUSINESS_ID }
                )
            )
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ failedInboundIngestionLog });

        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectAccountsByUniqueIdentifiersAndRecordType(
                    new Set<String>{ UNIQUE_IDENTIFER },
                    STORE_RECORD_TYPE_ID
                )
            )
            .thenReturn(new List<Account>{ storeAccount });

        mocks.stopStubbing();
        Application.SERVICE.setMock(
            IInstantIngestionRecordsGetterService.class,
            mockIInstantIngestionRecordGetterService
        );
        Application.SELECTOR.setMock(mockInboundIngestionSelector);
        Application.SELECTOR.setMock(mockQuotesSelector);
        Application.SELECTOR.setMock(mockMxOnboardingSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.UNITOFWORK.setMock(mockUOW);

        Instant_Ingestor__e mockInstantIngestorEvent = new Instant_Ingestor__e(
            Payload__c = JSON.serialize(new Set<Id>{ mockInboundingestionlogId }),
            Topic__c = EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED_RESSMO
        );
        InstantIngestionOnboardingService.execute(
            new List<Instant_Ingestor__e>{ mockInstantIngestorEvent }
        );
        Assert.areEqual(
            ONBOARDING_SOURCE,
            mockQuote.Integration_Source__c,
            'Integration Source should be updated to RESSMO'
        );
        Assert.areEqual(
            SUCESS_STATUS,
            mxol.Record_Creation_Status__c,
            'Record Creation Status should be Success'
        );
        Assert.areNotEqual(
            '',
            mockopp.Store_Id__c,
            'Opportunity storeId should be updated'
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerDirty(fflib_Match.sObjectWith(
            new map<sObjectField,Object>{
                Mx_Onboarding_Link__c.Inactive_Reason__c => INACTIVE_REASON_SUBMITTED,
                Mx_Onboarding_Link__c.Status__c => STATUS_INACTIVE
            }
        ));
    }

    @IsTest
    static void testWhenRESSMOMultiLocThenCreatStoreAndData() {
        Id mockBusinessVerticalId = Fake.generateId(Business_Vertical__c.class);
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id businessAccountId = Fake.generateId(Account.class);
        Id mockSubmarketId = Fake.generateId(Submarket__c.class);
        Id storeAccountId = Fake.generateId(Account.class);
        Id bizRefId = Fake.generateId(Business_Reference__c.class);
        Id mockBrandId = Fake.generateId(Brand__c.class);
        Id contactId = Fake.generateId(Contact.class);
        Id xrefId = Fake.generateId(Xref__c.class);

        Id contractId = Fake.generateId(Contract.class);

        Contact contact = new Contact(
            Id = contactId,
            Unique_Identifier__c = UNIQUE_IDENTIFER,
            AccountId = businessAccountId
        );

        Mx_Onboarding_Link__c mxol = new Mx_Onboarding_Link__c();
        mxol.Payload__c = '{}';

        Business_Vertical__c businessVerticalRx = new Business_Vertical__c(
            Id = mockBusinessVerticalId,
            Name = VERTICAL_RX
        );

        Submarket__c submarket = new Submarket__c(
            Id = mockSubmarketId,
            Submarket_ID__c = SUBMARKET_ID,
            Name = SUBMARKET_NAME
        );

        Fake bizFake = new Fake(Account.class)
            .setField(Account.Id, businessAccountId)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.RecordTypeId, BUSNINESS_RECORD_TYPE_ID)
            .setField(Account.CurrencyIsoCode, CURRENCY_ISO_CODE_USD)
            .setChildren(
                'Contracts',
                new List<Fake>{
                    new Fake(Contract.class)
                        .setField(Contract.AccountId, businessAccountId)
                        .setField(Contract.Payment_Method__c, null)
                        .setField(Contract.Id, contractId)
                }
            );
        Account bizAccount = (Account) bizFake.toSObject();

        Fake fakeStoreAccount = new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.RecordTypeId, STORE_RECORD_TYPE_ID)
            .setField(Account.Unique_Identifier__c, UNIQUE_IDENTIFER)
            .setField(Account.ParentId, businessAccountId)
            .setField(Account.CurrencyIsoCode, CURRENCY_ISO_CODE_USD)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setParent('Parent', bizFake);
        Account storeAccount = (Account) fakeStoreAccount.toSObject();

        Fake xrefFake = new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setParent('Salesforce_Account_Name__r', fakeStoreAccount);
        Xref__c xref = (Xref__c) xrefFake.toSObject();

        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        InstantIngestionPayloadParser payload = (InstantIngestionPayloadParser) System.JSON.deserialize(
            payloadString,
            InstantIngestionPayloadParser.class
        );

        Business_Reference__c bizref = new Business_Reference__c(
            Id = bizRefId,
            Unique_Identifier__c = UNIQUE_IDENTIFER,
            Brand__c = mockBrandId,
            Business_Name__c = BUSINESS_ACCOUNT_NAME,
            Business_Vertical__c = mockBusinessVerticalId,
            External_Id__c = BUSINESS_ID
        );
        Inbound_Ingestion_Log__c inboundIngestionLog = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            UUID__c = UNIQUE_IDENTIFER,
            Payload__c = JSON.serialize(payload),
            Integration_Type__c = ONBOARDING_EVENT
        );

        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID = new Map<String, InstantIngestionPayloadParser>{
            UNIQUE_IDENTIFER => payload
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );

        IXrefsSelector xrefsselectormock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);

        IInstantIngestionCheckRecordsService mockIInstantIngestionCheckRecordsService = (IInstantIngestionCheckRecordsService) mocks.mock(
            IInstantIngestionCheckRecordsService.class
        );

        IInstantIngestionRecordsGetterService mockIInstantIngestionRecordGetterService = (IInstantIngestionRecordsGetterService) mocks.mock(
            IInstantIngestionRecordsGetterService.class
        );

        IMxOnboardingLinksSelector mockMxOnboardingSelector = (IMxOnboardingLinksSelector) mocks.mock(
            IMxOnboardingLinksSelector.class
        );

        IInboundIngestionLogsSelector mockInboundIngestionSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );

        mocks.startStubbing();
        mocks.when(
                mockIInstantIngestionCheckRecordsService.getExistingBusinessAccounts(
                    //new Map<String, InstantIngestionPayloadParser>{UNIQUE_IDENTIFER => payload},
                    payLoadWrapperByIngestionLogUUID,
                    new Map<String, SSOBOnboardingPayloadParser>()
                )
            )
            .thenReturn(new Map<String, Account>{ BUSINESS_ID => bizAccount });

        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.getUltimateParentAccount(new Set<String>{ businessAccountId })
            )
            .thenReturn(new List<Account>{ bizAccount });

        mocks.when(
                xrefsselectormock.selectActiveXrefByExternalIdsAndExternalSourceMDSAndStoreRecordType(
                    new Set<String>{ STORE_ID }
                )
            )
            .thenReturn(new List<Xref__c>{ xref });
        mocks.when(
                mockIInstantIngestionCheckRecordsService.getExistingBusinessReferences(
                    new Set<String>{ BUSINESS_ID }
                )
            )
            .thenReturn(new Map<String, Business_Reference__c>{ BUSINESS_ID => bizref });
        mocks.when(
                mockIInstantIngestionRecordGetterService.getStoreAccountByUUID(
                    payLoadWrapperByIngestionLogUUID
                )
            )
            .thenReturn(new Map<String, Account>{ UNIQUE_IDENTIFER => storeAccount });

        mocks.when(
                mockIInstantIngestionCheckRecordsService.getExistingContactsByBusinessAccount(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(new Map<Id, Contact>{ businessAccountId => contact });
        mocks.when(
                mockIInstantIngestionCheckRecordsService.getExistingStoreAccounts(
                    payLoadWrapperByIngestionLogUUID
                )
            )
            .thenReturn(new Map<String, Account>{ BUSINESS_ID => storeAccount });
        mocks.when(
                mockIInstantIngestionRecordGetterService.getContactsByMatchedRecord(
                    payLoadWrapperByIngestionLogUUID
                )
            )
            .thenReturn(new Map<String, Contact>{ UNIQUE_IDENTIFER => contact });

        mocks.when(mockIInstantIngestionRecordGetterService.getRxBusinessVertical())
            .thenReturn(businessVerticalRx);
        mocks.when(
                mockIInstantIngestionRecordGetterService.getSubmarkets(
                    payLoadWrapperByIngestionLogUUID.values()
                )
            )
            .thenReturn(
                new Map<String, Submarket__c>{
                    payload.store.addressVerificationInfo.submarket.id => submarket
                }
            );
        mocks.when(mockMxOnboardingSelector.sObjectType())
            .thenReturn(Mx_Onboarding_Link__c.SObjectType);
        mocks.when(mockMxOnboardingSelector.selectByUUID(new Set<String>{ UNIQUE_IDENTIFER }))
            .thenReturn(new List<Mx_Onboarding_Link__c>{ mxol });

        mocks.when(mockInboundIngestionSelector.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(
                mockInboundIngestionSelector.selectInboundIngestionLogsByUUIDs(
                    payLoadWrapperByIngestionLogUUID.keyset()
                )
            )
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ inboundIngestionLog });

        mocks.stopStubbing();

        Application.SERVICE.setMock(
            IInstantIngestionRecordsGetterService.class,
            mockIInstantIngestionRecordGetterService
        );

        Application.SERVICE.setMock(
            IInstantIngestionCheckRecordsService.class,
            mockIInstantIngestionCheckRecordsService
        );
        Application.SELECTOR.setMock(mockInboundIngestionSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(xrefsselectormock);
        Application.SELECTOR.setMock(mockMxOnboardingSelector);
        Application.UNITOFWORK.setMock(mockUOW);

        (new InstantIngestionOnboardingServiceImpl())
            .initiateRESSMOMultiLoc(payLoadWrapperByIngestionLogUUID);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 6)).commitWork();
        Assert.areEqual(
            UNIQUE_IDENTIFER,
            storeAccount.Unique_Identifier__c,
            'Store should be created with Unique Identifier'
        );
    }

    @IsTest
    static void testWhenTwoQuotesWithSameUUIDThenProcessPrimaryQuote() {
        Id mockBusinessVerticalId = Fake.generateId(Business_Vertical__c.class);
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id mockFailedInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id xrefId = Fake.generateId(Xref__c.class);
        Id storeAccountId = Fake.generateId(Account.class);
        Id businessAccountId = Fake.generateId(Account.class);

        Mx_Onboarding_Link__c mxol = new Mx_Onboarding_Link__c();
        mxol.payload__c = '{}';
        mxol.UUID__c = UNIQUE_IDENTIFER;

        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        InstantIngestionPayloadParser payload = (InstantIngestionPayloadParser) System.JSON.deserialize(
            payloadString,
            InstantIngestionPayloadParser.class
        );
        payload.onboardingSource = ONBOARDING_SOURCE;

        Inbound_Ingestion_Log__c inboundIngestionLog = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            UUID__c = UNIQUE_IDENTIFER,
            Payload__c = payloadString,
            Integration_Type__c = ONBOARDING_EVENT,
            Source__c = ONBOARDING_SOURCE
        );
        Inbound_Ingestion_Log__c failedInboundIngestionLog = new Inbound_Ingestion_Log__c(
            Id = mockFailedInboundingestionlogId,
            UUID__c = UNIQUE_IDENTIFER,
            Payload__c = payloadString,
            Integration_Type__c = ONBOARDING_EVENT,
            Source__c = ONBOARDING_SOURCE,
            Business_Id__c = BUSINESS_ID
        );

        Business_Vertical__c businessVerticalRx = new Business_Vertical__c(
            Id = mockBusinessVerticalId,
            Name = VERTICAL_RX
        );

        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(Unique_Identifier__c = UNIQUE_IDENTIFER,SBQQ__Primary__c = false,SBQQ__Status__c = 'Approved');
        SBQQ__Quote__c mockDuplicateQuote = new SBQQ__Quote__c(Unique_Identifier__c = UNIQUE_IDENTIFER,SBQQ__Primary__c = true);

        Fake fakeStoreAccount = new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.RecordTypeId, STORE_RECORD_TYPE_ID)
            .setField(Account.Unique_Identifier__c, UNIQUE_IDENTIFER)
            .setField(Account.ParentId, businessAccountId)
            .setField(Account.CurrencyIsoCode, CURRENCY_ISO_CODE_USD)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.POS_Integration_Type__c, 'adora');
        Account storeAccount = (Account) fakeStoreAccount.toSObject();

        Fake xrefFake = new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.External_ID__c, STORE_ID)
            .setParent('Salesforce_Account_Name__r', fakeStoreAccount);
        Xref__c xref = (Xref__c) xrefFake.toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IInstantIngestionRecordsGetterService mockIInstantIngestionRecordGetterService = (IInstantIngestionRecordsGetterService) mocks.mock(
            IInstantIngestionRecordsGetterService.class
        );

        IMxOnboardingLinksSelector mockMxOnboardingSelector = (IMxOnboardingLinksSelector) mocks.mock(
            IMxOnboardingLinksSelector.class
        );

        IInboundIngestionLogsSelector mockInboundIngestionSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );

        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);

        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );

        IQuotesSelector mockQuotesSelector = (IQuotesSelector) mocks.mock(IQuotesSelector.class);

        mocks.startStubbing();

        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectActiveXrefByExternalIdsAndExternalSourceMDSAndStoreRecordType(
                    new Set<String>{ STORE_ID }
                )
            )
            .thenReturn(new List<Xref__c>{ xref });

        mocks.when(mockMxOnboardingSelector.sObjectType())
            .thenReturn(Mx_Onboarding_Link__c.SObjectType);
        mocks.when(mockMxOnboardingSelector.selectByUUID(new Set<String>{ UNIQUE_IDENTIFER }))
            .thenReturn(new List<Mx_Onboarding_Link__c>{ mxol });

        mocks.when(mockIInstantIngestionRecordGetterService.getRxBusinessVertical())
            .thenReturn(businessVerticalRx);

        mocks.when(mockQuotesSelector.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(
                mockQuotesSelector.selectQuotesbyUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFER }
                )
            )
            .thenReturn(new List<SBQQ__Quote__c>{ mockQuote , mockDuplicateQuote});

        mocks.when(mockInboundIngestionSelector.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(
                mockInboundIngestionSelector.selectById(new Set<Id>{ mockInboundingestionlogId })
            )
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ inboundIngestionLog });
        mocks.when(
                mockInboundIngestionSelector.selectFailedIngestionLogsByBizIds(
                    new Set<String>{ BUSINESS_ID }
                )
            )
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ failedInboundIngestionLog });

        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectAccountsByUniqueIdentifiersAndRecordType(
                    new Set<String>{ UNIQUE_IDENTIFER },
                    STORE_RECORD_TYPE_ID
                )
            )
            .thenReturn(new List<Account>{ storeAccount });

        mocks.stopStubbing();
        Application.SERVICE.setMock(
            IInstantIngestionRecordsGetterService.class,
            mockIInstantIngestionRecordGetterService
        );
        Application.SELECTOR.setMock(mockInboundIngestionSelector);
        Application.SELECTOR.setMock(mockQuotesSelector);
        Application.SELECTOR.setMock(mockMxOnboardingSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.UNITOFWORK.setMock(mockUOW);

        Instant_Ingestor__e mockInstantIngestorEvent = new Instant_Ingestor__e(
            Payload__c = JSON.serialize(new Set<Id>{ mockInboundingestionlogId }),
            Topic__c = EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED_RESSMO
        );
        InstantIngestionOnboardingService.execute(
            new List<Instant_Ingestor__e>{ mockInstantIngestorEvent }
        );
        Assert.areEqual(
            ONBOARDING_SOURCE,
            mockDuplicateQuote.Integration_Source__c,
            'Integration Source should be updated to RESSMO'
        );
        Assert.areEqual(
            SUCESS_STATUS,
            mxol.Record_Creation_Status__c,
            'Record Creation Status should be Success'
        );
        Assert.areEqual('Approved', mockQuote.SBQQ__Status__c,'Incorrect Quote got updated');
        Assert.areEqual('Contract Signed',mockDuplicateQuote.SBQQ__Status__c,'New Quote Didn\'t get updated');
    }
}