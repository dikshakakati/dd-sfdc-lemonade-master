/**
 * @author Deloitte
 * @date 06/06/2024
 * @description Test class for InstantIngestionCheckRecordsService class.
 */
@isTest(SeeAllData=false)
private class InstantIngestionCheckRecordsServiceTest {
    private static final String BUSINESS = 'Business';
    private static final String BUSINESS_ACCOUNT_NAME = 'Los Pinchos de mi Abuela';
    private static final String BUSINESS_ID = '12820285';
    private static final String CONTACT_OBJECT = 'Contact';
    private static final String EXTERNAL_ID = '3884328';
    private static final string INVALID_ASSERT_MESSAGE = 'Unexpected results';
    private static final String LEAD_OBJECT = 'Lead';
    private static final String OPPORTUNITY_DEAL_TYPE_STANDARD = 'Standard';
    private static final String OPPORTUNITY_STAGE_NAME_PROSPECTING = 'Prospecting';
    private static final String OPPORTUNITY_SUB_TYPE_NET_NEW = 'Net New Partner';
    private static final String OPPORTUNITY_TYPE_NEW = 'New';
    private static final String QUOTE_NUMBER = 'Q-123456';
    private static final String STATIC_RESOURCE_TEST_JSON = 'Inbound_Ingestion_Payload_Data';
    private static final String STATIC_RESOURCE_MX_PORTAL_JSON = 'Inbound_Ingestion_Payload_Mx_Portal_Data';
    private static final String STATIC_RESOURCE_NO_LEAD_ID = 'Inbound_Ingestion_Payload_Data_Without_Matched_Records';
    private static final String STORE = 'Store';
    private static final String STORE_ACCOUNT_NAME = 'Test Store Account';
    private static final String UNIQUE_IDENTIFER = '92108a53-e8d9-4a0c-9193-9152aeb86fe4';

    private static final Id BUSNINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Business')
        .getRecordTypeId();
    private static final Id STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Store')
        .getRecordTypeId();

    /**
     * @description It is used to check whether an account exist in the system with the same
     * business id received in the payload.
     */
    @isTest
    private static void testWhenPayloadThenBasedOnBusinessIdAccountNameReturns() {
        Id bizRefId = Fake.generateId(Business_Reference__c.class);
        Id xrefId = Fake.generateId(Xref__c.class);
        Id accountId = Fake.generateId(Account.class);
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
            Business_Name__c = BUSINESS_ACCOUNT_NAME,
            External_Id__c = BUSINESS_ID
        );

        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.Business_Reference__c, bizref.Id)
            .setField(Xref__c.BusinessID__c, BUSINESS_ID)
            .setField(Xref__c.Account_Record_Type__c, BUSINESS)
            .setParent(
                'Salesforce_Account_Name__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
                    .setField(Account.RecordTypeId, BUSNINESS_RECORD_TYPE_ID)
            )
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectXrefByBusinessReferenceExternalId(
                    new List<String>{ BUSINESS_ID }
                )
            )
            .thenReturn(new List<Xref__c>{ xref });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockXrefsSelector);

        Map<String, InstantIngestionPayloadParser> payloadByUUID = new Map<String, InstantIngestionPayloadParser>{
            payload.Uuid => payload
        };

        Test.startTest();
        Map<String, Account> businessAccountByBusinessId = InstantIngestionCheckRecordsService.getExistingBusinessAccounts(
            payloadByUUID,
            new Map<String, SSOBOnboardingPayloadParser>()
        );
        Test.stopTest();
        System.assertEquals(
            businessAccountByBusinessId.get(BUSINESS_ID).Name,
            payload.business.Name,
            INVALID_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to check whether an store's parent account exist in the system with the same
     * business id received in the payload.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPayloadThenBasedOnBusinessIdAccountNameViaStoreReturns() {
        Id bizRefId = Fake.generateId(Business_Reference__c.class);
        Id xrefId = Fake.generateId(Xref__c.class);
        Id accountId = Fake.generateId(Account.class);
        Id accountParentId = Fake.generateId(Account.class);

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
            Business_Name__c = BUSINESS_ACCOUNT_NAME,
            External_Id__c = BUSINESS_ID
        );

        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.Business_Reference__c, bizref.Id)
            .setField(Xref__c.BusinessID__c, BUSINESS_ID)
            .setField(Xref__c.Account_Record_Type__c, STORE)
            .setParent(
                'Salesforce_Account_Name__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.Name, STORE_ACCOUNT_NAME)
                    .setField(Account.ParentId, accountParentId)
                    .setField(Account.RecordTypeId, STORE_RECORD_TYPE_ID)
            )
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectXrefByBusinessReferenceExternalId(
                    new List<String>{ BUSINESS_ID }
                )
            )
            .thenReturn(new List<Xref__c>{ xref });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockXrefsSelector);

        Map<String, InstantIngestionPayloadParser> payloadByUUID = new Map<String, InstantIngestionPayloadParser>{
            payload.Uuid => payload
        };

        Test.startTest();
        InstantIngestionCheckRecordsService.getExistingBusinessAccounts(
            payloadByUUID,
            new Map<String, SSOBOnboardingPayloadParser>()
        );
        Test.stopTest();
    }

    /**
     * @description It is used to test whether a Lead and Contact exists in the system with the same
     * lead id or Contact Id received in the payload.
     */
    @isTest
    private static void testWhenPayloadPassedThenCheckLeadAndContactPresentInSystem() {
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
        Map<String, InstantIngestionPayloadParser> payloadByUUID = new Map<String, InstantIngestionPayloadParser>{
            payload.Uuid => payload
        };
        Test.startTest();
        Map<Id, String> leadIdToUniqueId = InstantIngestionCheckRecordsService.getExistingSObjectsByMatchedRecordId(
            payloadByUUID,
            LEAD_OBJECT
        );
        Map<Id, String> contactIdToUniqueId = InstantIngestionCheckRecordsService.getExistingSObjectsByMatchedRecordId(
            payloadByUUID,
            CONTACT_OBJECT
        );
        Boolean checkLeadIsPresentInSystem = leadIdToUniqueId.containsKey(
            payload.store.matchedRecords.lead[0].id
        );
        Boolean checkContactIsPresentInSystem = contactIdToUniqueId.containsKey(
            payload.store.matchedRecords.contact[0].id
        );
        Test.stopTest();
        System.assertEquals(checkLeadIsPresentInSystem, true, INVALID_ASSERT_MESSAGE);
        System.assertEquals(checkContactIsPresentInSystem, true, INVALID_ASSERT_MESSAGE);
    }
    /**
     * @description It is used to test whether a lead exist in the system with the same
     * lead id received in the payload.
     */
    @isTest
    private static void testWhenPayloadWithNoLeadPassedThenLeadNotPresentInSystem() {
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_NO_LEAD_ID
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        InstantIngestionPayloadParser payload = (InstantIngestionPayloadParser) System.JSON.deserialize(
            payloadString,
            InstantIngestionPayloadParser.class
        );
        Map<String, InstantIngestionPayloadParser> payloadByUUID = new Map<String, InstantIngestionPayloadParser>{
            payload.Uuid => payload
        };

        Test.startTest();
        Map<Id, String> leadIdToUniqueId = InstantIngestionCheckRecordsService.getExistingSObjectsByMatchedRecordId(
            payloadByUUID,
            LEAD_OBJECT
        );
        Boolean checkLeadIsPresentInSystem = leadIdToUniqueId.containsKey(
            payload.store.matchedRecords.lead[0].id
        );
        Test.stopTest();
        System.assertEquals(true, checkLeadIsPresentInSystem, INVALID_ASSERT_MESSAGE);
    }

    /**
     * @description It is used to check whether an store account exist in the system with the same
     * business id received in the payload.
     */
    @isTest
    private static void testWhenPayloadThenBasedOnBusinessIdStoreAccountNameReturns() {
        Id bizRefId = Fake.generateId(Business_Reference__c.class);
        Id xrefId = Fake.generateId(Xref__c.class);
        Id accountId = Fake.generateId(Account.class);
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
            Business_Name__c = BUSINESS_ACCOUNT_NAME,
            External_Id__c = BUSINESS_ID
        );

        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.Business_Reference__c, bizref.Id)
            .setField(Xref__c.BusinessID__c, BUSINESS_ID)
            .setField(Xref__c.Account_Record_Type__c, STORE)
            .setParent(
                'Salesforce_Account_Name__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
                    .setField(Account.RecordTypeId, STORE_RECORD_TYPE_ID)
            )
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectXrefByBusinessReferenceExternalId(
                    new List<String>{ BUSINESS_ID }
                )
            )
            .thenReturn(new List<Xref__c>{ xref });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockXrefsSelector);

        Map<String, InstantIngestionPayloadParser> payloadByUUID = new Map<String, InstantIngestionPayloadParser>{
            payload.Uuid => payload
        };

        Test.startTest();
        Map<String, Account> businessAccountByBusinessId = InstantIngestionCheckRecordsService.getExistingStoreAccounts(
            payloadByUUID
        );
        Test.stopTest();
        System.assertEquals(
            businessAccountByBusinessId.get(BUSINESS_ID).Name,
            payload.business.Name,
            INVALID_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to check whether an opportunitty exist in the system when the accountId passed
     */
    @isTest
    private static void testWhenAccountIdPassedThenOpportunityReturns() {
        Id businessAccountId = Fake.generateId(Account.class);
        Id opportunityId = Fake.generateId(Opportunity.class);
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);

        Opportunity testOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_NAME_PROSPECTING)
            .setField(Opportunity.Type, OPPORTUNITY_TYPE_NEW)
            .setField(Opportunity.Opportunity_Sub_Type__c, OPPORTUNITY_SUB_TYPE_NET_NEW)
            .setField(Opportunity.CloseDate, Date.today() + 1)
            .setField(Opportunity.Deal_Type__c, OPPORTUNITY_DEAL_TYPE_STANDARD)
            .setField(Opportunity.SBQQ__PrimaryQuote__c, quoteId)
            .setField(Opportunity.AccountId, businessAccountId)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IOpportunitiesSelector mockOpportunitiesSelector = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockOpportunitiesSelector.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(
                mockOpportunitiesSelector.getExistingOpportunitiesAndPrimaryQuotesbyAccountNames(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(new List<Opportunity>{ testOpportunity });

        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockOpportunitiesSelector);

        Test.startTest();
        Map<Id, Opportunity> opportunityByAccountId = InstantIngestionCheckRecordsService.fetchRelatedOpportunitiesAndQuotes(
            new Set<Id>{ businessAccountId }
        );
        Test.stopTest();
        System.assertEquals(
            opportunityByAccountId.get(businessAccountId).AccountId,
            businessAccountId,
            INVALID_ASSERT_MESSAGE
        );
    }
    /**
     * @description It is used to check whether a brand exist in the system when the accountId passed
     */
    @isTest
    private static void testWhenAccountIdPassedThenBrandReturns() {
        Id businessAccountId = Fake.generateId(Account.class);
        Id brandId = Fake.generateId(Brand__c.class);

        Brand__c testBrand = (Brand__c) new Fake(Brand__c.class)
            .setField(Brand__c.Id, brandId)
            .setField(Brand__c.Unique_Identifier__c, UNIQUE_IDENTIFER)
            .setField(Brand__c.Brand_Owner__c, businessAccountId)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IbrandsSelector mockbrandSelector = (IbrandsSelector) mocks.mock(IbrandsSelector.class);
        mocks.startStubbing();
        mocks.when(mockbrandSelector.sObjectType()).thenReturn(Brand__c.SObjectType);
        mocks.when(mockbrandSelector.selectBrandsByAccountIds(new Set<Id>{ businessAccountId }))
            .thenReturn(new List<Brand__c>{ testBrand });

        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockbrandSelector);

        Test.startTest();
        Map<Id, Brand__c> brandByAccountId = InstantIngestionCheckRecordsService.getExistingBrands(
            new Set<Id>{ businessAccountId }
        );
        Test.stopTest();
        System.assertEquals(
            brandByAccountId.get(businessAccountId).Brand_Owner__c,
            businessAccountId,
            INVALID_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to check whether a Business References exist in the system when the businessId passed
     */
    @isTest
    private static void testWhenBusinessIdPassedThenBusinessReferencesReturns() {
        Id businessReferenceId = Fake.generateId(Business_Reference__c.class);

        Business_Reference__c testbusinessReference = (Business_Reference__c) new Fake(
                Business_Reference__c.class
            )
            .setField(Business_Reference__c.Id, businessReferenceId)
            .setField(Business_Reference__c.External_ID__c, BUSINESS_ID)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IBusinessReferencesSelector mockBusinessRefSelector = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockBusinessRefSelector.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(mockBusinessRefSelector.selectBusRefByExternalId(new Set<String>{ BUSINESS_ID }))
            .thenReturn(new List<Business_Reference__c>{ testbusinessReference });

        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockBusinessRefSelector);

        Test.startTest();
        Map<String, Business_Reference__c> bizRefByBusinessId = InstantIngestionCheckRecordsService.getExistingBusinessReferences(
            new Set<String>{ BUSINESS_ID }
        );
        Test.stopTest();
        System.assertEquals(
            bizRefByBusinessId.get(BUSINESS_ID).External_ID__c,
            BUSINESS_ID,
            INVALID_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to check whether a contact exist in the system when the accountId passed
     */
    @isTest
    private static void testWhenAccountIdPassedThenContactReturns() {
        Id accountId = Fake.generateId(Account.class);
        Id contactId = Fake.generateId(Contact.class);

        Contact testContact = (Contact) new Fake(Contact.class)
            .setField(Contact.Id, contactId)
            .setField(Contact.AccountId, accountId)
            .setField(Contact.Unique_Identifier__c, UNIQUE_IDENTIFER)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IContactsSelector mockContactSelector = (IContactsSelector) mocks.mock(
            IContactsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockContactSelector.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(mockContactSelector.selectContactsByAccountIds(new Set<Id>{ accountId }))
            .thenReturn(new List<Contact>{ testContact });

        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockContactSelector);

        Test.startTest();
        Map<Id, Contact> contactByAccountId = InstantIngestionCheckRecordsService.getExistingContactsByBusinessAccount(
            new Set<Id>{ accountId }
        );
        Test.stopTest();
        System.assertEquals(
            contactByAccountId.get(accountId).AccountId,
            accountId,
            INVALID_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to check whether a quote exist in the system when the opportunityId passed
     */
    @isTest
    private static void testWhenOpportunityIdPassedThenQuoteReturns() {
        Id businessaccountId = Fake.generateId(Account.class);
        Id opportunityId = Fake.generateId(Opportunity.class);
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);

        SBQQ__Quote__c testQuote = (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityId)
            .setField(SBQQ__Quote__c.SBQQ__Account__c, businessaccountId)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IQuotesSelector mockQuoteSelector = (IQuotesSelector) mocks.mock(IQuotesSelector.class);
        mocks.startStubbing();
        mocks.when(mockQuoteSelector.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(mockQuoteSelector.selectByOpportunity(new Set<Id>{ opportunityId }))
            .thenReturn(new List<SBQQ__Quote__c>{ testQuote });

        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockQuoteSelector);

        Test.startTest();
        Map<Id, SBQQ__Quote__c> quoteByAccountId = InstantIngestionCheckRecordsService.getExistingQuotesByAccountIds(
            new Set<Id>{ opportunityId }
        );
        Test.stopTest();
        System.assertEquals(
            quoteByAccountId.get(businessaccountId).SBQQ__Account__c,
            businessaccountId,
            INVALID_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to check whether a store exist in the system with the same
     * store id received in the payload.
     */
    @isTest
    private static void testWhenMxPortalPayloadIsPassedThenExistingStoreAccountByStoreIdReturned() {
        Id bizRefId = Fake.generateId(Business_Reference__c.class);
        Id xrefId = Fake.generateId(Xref__c.class);
        Id accountId = Fake.generateId(Account.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_MX_PORTAL_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        MxPortalPayloadParser payload = (MxPortalPayloadParser) System.JSON.deserialize(
            payloadString,
            MxPortalPayloadParser.class
        );
        Business_Reference__c bizref = new Business_Reference__c(
            Id = bizRefId,
            Business_Name__c = BUSINESS_ACCOUNT_NAME,
            External_Id__c = BUSINESS_ID
        );

        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.Business_Reference__c, bizref.Id)
            .setField(Xref__c.External_ID__c, EXTERNAL_ID)
            .setField(Xref__c.Account_Record_Type__c, BUSINESS)
            .setField(Xref__c.Salesforce_Account_Name__c, accountId)
            .setParent(
                'Salesforce_Account_Name__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
                    .setField(Account.RecordTypeId, BUSNINESS_RECORD_TYPE_ID)
            )
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(mockXrefsSelector.selectXrefByExternalIdOnly(new List<String>{ EXTERNAL_ID }))
            .thenReturn(new List<Xref__c>{ xref });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockXrefsSelector);

        Map<String, MxPortalPayloadParser> payloadByUUID = new Map<String, MxPortalPayloadParser>{
            payload.Uuid => payload
        };
        Test.startTest();
        Map<String, Account> storeIds = InstantIngestionCheckRecordsService.checkAndFetchExistingStoreAccountsByStoreId(
            payloadByUUID
        );
        Boolean isAccountPresent = storeIds.get(payload.store.storeId) == null ? true : false;
        Test.stopTest();
        System.assertEquals(false, isAccountPresent, INVALID_ASSERT_MESSAGE);
    }
}