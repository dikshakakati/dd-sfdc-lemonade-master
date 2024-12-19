/**
 * @author DoorDash
 * @date 03/22/2023
 * @description Test class for IntegrationRequestsService class.
 */
@isTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class CooSameStoreServiceImplTest {
    private static final String EVENT_TOPIC_PROCESS_COO_SAME_STORE = 'PROCESS_COO_SAME_STORE';
    private static final String IR_BATCH_ID = 'Batch001';
    private static final String IR_BATCH_ID_FOR_FUZZY_MATCH = 'Batch002';
    private static final String IR_STATUS_PENDING= 'Pending';
    private static final String IR_STATUS_READY = 'ready';
    private static final String IR_STATUS_PROCESSED= 'Processed';
    private static final String IR_PRODUCT_STATUS_CREATED= 'created';
    private static final String IR_PRODUCT_STATUS_CANCELLED= 'cancelled';
    private static final String IR_PRODUCT_STATUS_COMPLETED= 'completed';
    private static final String IR_PRODUCT_STATUS_READY= 'ready';
    private static final Set<String> PAYMENT_ACCOUNT_RECORD_TYPES = new Set<String>{'Invoice', 'Payments'};
    private static final String INTEGRATION_PROVIDER = 'adora';


    @isTest
    private static void testWhenNewCooReqReceivedThenCreateOpportunity() {
        // Create test data: Integration Requests
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Integration_Request__c integrationRequest1 = new Integration_Request__c(
            Id = fflib_IDGenerator.generate(Integration_Request__c.SObjectType),
            sfdc_status__c = IR_STATUS_PENDING,
            Batch_Id__c = IR_BATCH_ID,
            Product_status__c = IR_PRODUCT_STATUS_CREATED,
            Account__r = new Account(parentId = parentAccountId)
        );
        List<Integration_Request__c> intReqByBatch = new List<Integration_Request__c>{
            integrationRequest1
        };
        Set<String> batchIds = new Set<String>{IR_BATCH_ID};
        // Set up mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        Application.UnitOfWork.setMock(uowMock);
        CooSameStoreServiceImpl cooService = new CooSameStoreServiceImpl();
        cooService.processNewCooRequests(intReqByBatch, batchIds);

       ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerNew(fflib_Match.sObjectsWith(
            new List<Map<SObjectField, Object>>{
                new Map<SObjectField, Object>{
                    Opportunity.AccountId => parentAccountId
                }
            }
        ));
          //-- verify
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
        .registerDirty(
            fflib_Match.sObjectWith(
                new Map<SObjectField, Object>{
                    Integration_Request__c.sfdc_status__c => IR_STATUS_PROCESSED
                }
            )
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
        .registerDirty(
            fflib_Match.sObjectWith(
                new Map<SObjectField, Object>{
                    Account.Integration_Request__c => integrationRequest1.id
                }
            )
        );
    }
    @isTest
    private static void testWhenCancelledIntReqReceivedThenCloseTheOpportunity() {
        // Create test data: Integration Requests
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Integration_Request__c parentIntReq = new Integration_Request__c(
            Id = fflib_IDGenerator.generate(Integration_Request__c.SObjectType),
            opportunity__c = opportunityId
        );
        Integration_Request__c integrationRequest1 = new Integration_Request__c(
            Id = fflib_IDGenerator.generate(Integration_Request__c.SObjectType),
            sfdc_status__c = IR_STATUS_PENDING,
            Batch_Id__c = IR_BATCH_ID,
            Product_status__c = IR_PRODUCT_STATUS_CANCELLED,
            Parent_Integration_Request__r =  parentIntReq
        );
        List<Integration_Request__c> intReqByBatch = new List<Integration_Request__c>{
            integrationRequest1
        };

        // Set up mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        Application.UnitOfWork.setMock(uowMock);
        CooSameStoreServiceImpl cooService = new CooSameStoreServiceImpl();
        cooService.processCancelledCooRequests(intReqByBatch);

        // Verify that the Opportunity is marked as 'Closed Lost' when the Integration Request is cancelled and IR_STATUS_PROCESSED
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerDirty(fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                Opportunity.Id => opportunityId,
                Opportunity.StageName => 'Closed Lost'
            }
        ));

        // Verify that the Integration Request is marked as IR_STATUS_PROCESSED
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerDirty(fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                Integration_Request__c.Id => integrationRequest1.Id,
                Integration_Request__c.sfdc_status__c => IR_STATUS_PROCESSED
            }
        ));
    }
    @isTest
    private static void testWhenIntReqCancelledCooRequestsThenDoNotCloseOpportunity() {
        // Create test data: Integration Requests
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Integration_Request__c integrationRequest1 = new Integration_Request__c(
            Id = fflib_IDGenerator.generate(Integration_Request__c.SObjectType),
            sfdc_status__c = IR_STATUS_PENDING,
            Batch_Id__c = IR_BATCH_ID,
            Product_status__c = IR_PRODUCT_STATUS_CREATED, // Not cancelled to make sure Batch_Id__c is in the set batchIdsOppToNotCancel
            opportunity__c = opportunityId
        );
        Integration_Request__c integrationRequest2 = new Integration_Request__c(
            Id = fflib_IDGenerator.generate(Integration_Request__c.SObjectType),
            sfdc_status__c = IR_STATUS_PENDING,
            Batch_Id__c = IR_BATCH_ID,
            Product_status__c = IR_PRODUCT_STATUS_CANCELLED,
            opportunity__c = opportunityId
        );
        List<Integration_Request__c> intReqByBatch = new List<Integration_Request__c>{
            integrationRequest1, integrationRequest2
        };

        // Set up mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        Application.UnitOfWork.setMock(uowMock);
        CooSameStoreServiceImpl cooService = new CooSameStoreServiceImpl();
        cooService.processCancelledCooRequests(intReqByBatch);
        // Verify that the Integration Request with cancelled product status is marked as IR_STATUS_PROCESSED
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerDirty(fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                Integration_Request__c.Id => integrationRequest2.Id,
                Integration_Request__c.sfdc_status__c => IR_STATUS_PROCESSED
            }
        ));
    }

    @isTest
    static void testWhenCompletedIntReceivedThenCloseWonTheOpportunityIfAllIntReqCompletedForThatBatch() {
        // Prepare mock data
        Id oppId1 = fflib_IDGenerator.generate(opportunity.SObjectType);
        Id accountId1 = fflib_IDGenerator.generate(Account.SObjectType);
        Id accountId2 = fflib_IDGenerator.generate(Account.SObjectType);
        Integration_Request__c mockIntegrationRequest1 = new Integration_Request__c(
            onBoarding_Id__c = 'onboarding01',
            batch_Id__c = 'B001',
            opportunity__c = oppId1,
            Product_Status__c = IR_PRODUCT_STATUS_COMPLETED,
            Account__c = accountId1,
            payload__c = mockPayloadData()
        );

        Integration_Request__c mockIntegrationRequest2 = new Integration_Request__c(
            onBoarding_Id__c = 'onboarding02',
            batch_Id__c = 'B002',
            opportunity__c = oppId1,
            Product_Status__c = IR_PRODUCT_STATUS_COMPLETED,
            Account__c = accountId2,
            payload__c = mockPayloadData()
        );

        // Put mock data into list
        List<Integration_Request__c> intReqByBatch = new List<Integration_Request__c>{
            mockIntegrationRequest1,
            mockIntegrationRequest2
        };

        // Create a map with the mock data
        Map<Id, Id> intIdToAccountId = new Map<Id, Id>();
        intIdToAccountId.put(mockIntegrationRequest1.Id, accountId1);
        intIdToAccountId.put(mockIntegrationRequest2.Id, accountId2);
		Set<String> batchIds = new Set<String>{'B001', 'B002'};
               // Set up mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        IIntegrationRequestsSelector integrationSelectorMock = (IIntegrationRequestsSelector) mocks.mock(IIntegrationRequestsSelector.class);
        mocks.startStubbing();
        mocks.when(IntegrationSelectorMock.SObjectType()).thenReturn(Integration_Request__c.SObjectType);
        mocks.when(IntegrationSelectorMock.selectByBatchId(batchIds)).thenReturn(intReqByBatch);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(IntegrationSelectorMock);
        Application.UnitOfWork.setMock(uowMock);
        CooSameStoreServiceImpl cooService = new CooSameStoreServiceImpl();
        cooService.getIntegrationRequests(batchIds);
        cooService.updateOpportunityToClosedWon(intIdToAccountId, intReqByBatch);


        // Verify that the Opportunity is marked as 'Closed Won' when the Integration Request is cancelled and IR_STATUS_PROCESSED
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 2)).registerDirty(fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                Opportunity.Id => oppId1,
                Opportunity.StageName => 'Closed Won'
            }
        ));
    }

    @isTest
    static void testWhenEventsArePublishedThenSubscribeFromCooServiceAndProcess() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Integration_Request__c integrationRequest1 = new Integration_Request__c(
            Id = fflib_IDGenerator.generate(Integration_Request__c.SObjectType),
            sfdc_status__c = IR_STATUS_PENDING,
            Batch_Id__c = IR_BATCH_ID,
            Product_status__c = IR_PRODUCT_STATUS_CREATED,
            Account__r = new Account(parentId = parentAccountId),
            payload__c = mockPayloadData()
        );
        List<Integration_Request__c> intReqByBatch = new List<Integration_Request__c>{
            integrationRequest1
        };

        String eventPayload = JSON.serialize(new Set<String>{ IR_BATCH_ID });

        // Set up mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        IIntegrationRequestsSelector integrationSelectorMock = (IIntegrationRequestsSelector) mocks.mock(IIntegrationRequestsSelector.class);
        mocks.startStubbing();
        mocks.when(IntegrationSelectorMock.SObjectType()).thenReturn(Integration_Request__c.SObjectType);
        mocks.when(IntegrationSelectorMock.selectByBatchId(new Set<String>{IR_BATCH_ID})).thenReturn(intReqByBatch);
        mocks.stopStubbing();
        Application.UnitOfWork.setMock(uowMock);
        Application.SELECTOR.setMock(IntegrationSelectorMock);

        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_PROCESS_COO_SAME_STORE
        );
        CooSameStoreService.execute(new List<Notifier__e>{ mockNotifierEvent });

        ((IIntegrationRequestsSelector) mocks.verify(integrationSelectorMock, 1))
            .selectByBatchId(
                new Set<String>{ IR_BATCH_ID }
            );
    }
    //LEM-16130
    @isTest
    static void testWhenCompletedIntReqReceivedThenFuzzyMatchAccount() {
        Account accountToBeInserted = new Account(
            Name = 'Test Busines',
            BillingStreet = '123 Main St',
            BillingPostalCode = '12345',
            Type = 'Corporate',
            Segment__c ='SMB'
        );
        insert accountToBeInserted;
        Integration_Request__c integrationRequestParentForFuzzyMatch = new Integration_Request__c(
            Id = fflib_IDGenerator.generate(Integration_Request__c.SObjectType),
            sfdc_status__c = IR_STATUS_PROCESSED,
            payload__c = mockPayloadData()
        );
        Integration_Request__c integrationRequestForFuzzyMatch = new Integration_Request__c(
            Id = fflib_IDGenerator.generate(Integration_Request__c.SObjectType),
            sfdc_status__c = IR_STATUS_PENDING,
            Batch_Id__c = IR_BATCH_ID_FOR_FUZZY_MATCH,
            Parent_Integration_Request__c = integrationRequestParentForFuzzyMatch.Id,
            Product_status__c = IR_PRODUCT_STATUS_COMPLETED,
            payload__c = mockPayloadData()
        );

        Set<String> batchIds = new Set<String>{IR_BATCH_ID_FOR_FUZZY_MATCH};
        List<Integration_Request__c> intRequests  = new List<Integration_Request__c>{integrationRequestForFuzzyMatch};

        //Mock selector
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        IIntegrationRequestsSelector integrationSelectorMock = (IIntegrationRequestsSelector) mocks.mock(IIntegrationRequestsSelector.class);
        mocks.startStubbing();
        mocks.when(IntegrationSelectorMock.SObjectType()).thenReturn(Integration_Request__c.SObjectType);
        mocks.when(IntegrationSelectorMock.selectByBatchId(batchIds)).thenReturn(intRequests);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(IntegrationSelectorMock);
        Application.UnitOfWork.setMock(uowMock);
        CooSameStoreServiceImpl cooService = new CooSameStoreServiceImpl();
        cooService.getIntegrationRequests(batchIds);
        cooService.findOrCreateBusinessAccount(intRequests);

        ((IIntegrationRequestsSelector) mocks.verify(integrationSelectorMock, 1))
            .selectByBatchId(
                new Set<String>{ IR_BATCH_ID_FOR_FUZZY_MATCH }
        );
    }
    @isTest
    static void testWhenCompletedIntReqReceivedThenCreateBusinessAccount() {
        Account act = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Name = 'Test Account',
            Address_Id__c = '3838383'
        );
        Id intId = fflib_IDGenerator.generate(Integration_Request__c.SObjectType);
        Integration_Request__c integrationRequest = new Integration_Request__c(
            Id = intId,
            sfdc_status__c = IR_STATUS_PENDING,
            Batch_Id__c = IR_BATCH_ID,
            Product_status__c = IR_PRODUCT_STATUS_COMPLETED,
            payload__c = mockPayloadData()
        );
        Set<String> accountNames = new Set<String>{'Test Account'};
        Set<String> addressIds = new Set<String>{'383838383'};
        Set<String> batchIds = new Set<String>{IR_BATCH_ID};
        List<Account> accounts  = new List<Account>{act};
        List<Integration_Request__c> intRequests  = new List<Integration_Request__c>{integrationRequest};
        // Mock selector
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        fflib_ISObjectUnitOfWork mockUow = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        IIntegrationRequestsSelector integrationSelectorMock = (IIntegrationRequestsSelector) mocks.mock(IIntegrationRequestsSelector.class);

        mocks.startStubbing();
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(mockAccountsSelector.selectBusinessAccountsWithNameAndAddressId(accountNames, addressIds)).thenReturn(accounts);
        mocks.when(mockAccountsSelector.selectById(new Set<Id>())).thenReturn(new List<Account>());
        mocks.when(mockAccountsSelector.selectNonFranchiseeAccountsById(new Set<Id>())).thenReturn(new List<Account>());
        mocks.when(IntegrationSelectorMock.SObjectType()).thenReturn(Integration_Request__c.SObjectType);
        mocks.when(IntegrationSelectorMock.selectByBatchId(batchIds)).thenReturn(intRequests);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(IntegrationSelectorMock);
        Application.UnitOfWork.setMock(mockUow);
        //CooTransactionsDto dto = new CooTransactionsDto(intRequests);
        CooSameStoreServiceImpl cooService = new CooSameStoreServiceImpl();
        cooService.getIntegrationRequests(batchIds);
        cooService.findOrCreateBusinessAccount(intRequests);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerNew(fflib_Match.sObjectsWith(
            new List<Map<SObjectField, Object>>{
                new Map<SObjectField, Object>{
                    Account.Creation_Source__c => 'Integration'
                }
            }
        ));

    }
     @isTest
    static void testWhenCompletedIntReqReceivedThenCreateBusinessReference() {
         Business_Reference__c businessRef = new Business_Reference__c(
            Id = fflib_IDGenerator.generate(Business_Reference__c.SObjectType),
            External_Id__c = 'Test Id01'
        );
         Id intId = fflib_IDGenerator.generate(Integration_Request__c.SObjectType);
         Id accountId =  fflib_IDGenerator.generate(Account.SObjectType);
        Integration_Request__c integrationRequest = new Integration_Request__c(
            Id = intId,
            sfdc_status__c = IR_STATUS_PENDING,
            Batch_Id__c = IR_BATCH_ID,
            Product_status__c = IR_PRODUCT_STATUS_COMPLETED,
            business_Id__c = '32323232',
            payload__c = mockPayloadData()
        );
        Set<String> batchIds = new Set<String>{IR_BATCH_ID};
        List<Business_Reference__c> busRefs = new List<Business_Reference__c>{businessRef};
        List<Integration_Request__c> intRequests  = new List<Integration_Request__c>{integrationRequest};
        Set<String> businessIds = new Set<String>{'9999999'};
            Map<Id, Id> intIdToBusinessActId =  new Map<Id, Id>{integrationRequest.Id => accountId};
        // Mock selector
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        IIntegrationRequestsSelector integrationSelectorMock = (IIntegrationRequestsSelector) mocks.mock(IIntegrationRequestsSelector.class);
        IBusinessReferencesSelector businessRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(IBusinessReferencesSelector.class);

        mocks.startStubbing();
        mocks.when(IntegrationSelectorMock.SObjectType()).thenReturn(Integration_Request__c.SObjectType);
        mocks.when(IntegrationSelectorMock.selectByBatchId(batchIds)).thenReturn(intRequests);
        mocks.when(businessRefSelectorMock.SObjectType()).thenReturn(Business_Reference__c.SObjectType);
        mocks.when(businessRefSelectorMock.selectBusRefByExternalId(businessIds)).thenReturn(busRefs);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(IntegrationSelectorMock);
        Application.SELECTOR.setMock(businessRefSelectorMock);
        Application.UnitOfWork.setMock(mockUow);
        //CooTransactionsDto dto = new CooTransactionsDto(intRequests);
        CooSameStoreServiceImpl cooService = new CooSameStoreServiceImpl();
        cooService.getIntegrationRequests(batchIds);
        cooService.findOrCreateBusinessReference(intRequests, intIdToBusinessActId);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerNew(fflib_Match.sObjectsWith(
            new List<Map<SObjectField, Object>>{
                new Map<SObjectField, Object>{
                    Business_Reference__c.Business_Name__c => 'Test Business'
                }
            }
        ));
    }
     @isTest
    static void testWhenCompletedIntReqReceivedThenUpdateXrefWithLatestBusinessRef() {
        Id businessRefId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
         Xref__c xref = new Xref__c(
            Id = fflib_IDGenerator.generate(Xref__c.SObjectType),
            External_Id__c = '1234'
        );
        Id intId = fflib_IDGenerator.generate(Integration_Request__c.SObjectType);
        Integration_Request__c integrationRequest = new Integration_Request__c(
            Id = intId,
            sfdc_status__c = IR_STATUS_PENDING,
            Batch_Id__c = IR_BATCH_ID,
            Product_status__c = IR_PRODUCT_STATUS_COMPLETED,
            business_Id__c = '32323232',
            store_Id__c = '1234'
        );
        List<Xref__c> xrefs = new List<Xref__c>{xref};
        List<String> storeIds = new List<String>{'1234'};
        List<Integration_Request__c> intRequests  = new List<Integration_Request__c>{integrationRequest};
        Map<Id, Id> intIdToBusinessRefId =  new Map<Id, Id>{intId => businessRefId};
        // Mock selector
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        IIntegrationRequestsSelector integrationSelectorMock = (IIntegrationRequestsSelector) mocks.mock(IIntegrationRequestsSelector.class);
        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);

        mocks.startStubbing();
        mocks.when(IntegrationSelectorMock.SObjectType()).thenReturn(Integration_Request__c.SObjectType);
        mocks.when(xrefSelectorMock.SObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefSelectorMock.selectXrefByExternalId(storeIds)).thenReturn(xrefs);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(IntegrationSelectorMock);
        Application.SELECTOR.setMock(xrefSelectorMock);
        Application.UnitOfWork.setMock(mockUow);
        //CooTransactionsDto dto = new CooTransactionsDto(intRequests);
        CooSameStoreServiceImpl cooService = new CooSameStoreServiceImpl();
        cooService.updateXrefWithLatestBusinessRefId(intRequests, intIdToBusinessRefId);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerDirty(fflib_Match.sObjectWith
                (new Map<SObjectField, Object>{
                Xref__c.Business_Reference__c => businessRefId
        }));
    }
    @isTest
    static void testWhenCompletedIntReqReceivedThenReparentTheStoreToNewBusinessAccount() {
        Id intId = fflib_IDGenerator.generate(Integration_Request__c.SObjectType);
        Id parentActId =  fflib_IDGenerator.generate(Account.SObjectType);
        Integration_Request__c integrationRequest = new Integration_Request__c(
            Id = intId,
            Account__C = fflib_IDGenerator.generate(Account.SObjectType),
            sfdc_status__c = IR_STATUS_PENDING,
            Batch_Id__c = IR_BATCH_ID,
            Product_status__c = IR_PRODUCT_STATUS_COMPLETED,
            business_Id__c = '32323232',
            payload__c = mockPayloadData()
        );
        Set<String> batchIds = new Set<String>{IR_BATCH_ID};
        List<Integration_Request__c> intRequests  = new List<Integration_Request__c>{integrationRequest};
        Map<Id, Id> intIdToBusinessActId =  new Map<Id, Id>{integrationRequest.Id => parentActId};
        // Mock selector
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        IIntegrationRequestsSelector integrationSelectorMock = (IIntegrationRequestsSelector) mocks.mock(IIntegrationRequestsSelector.class);

        mocks.startStubbing();
        mocks.when(IntegrationSelectorMock.SObjectType()).thenReturn(Integration_Request__c.SObjectType);
        mocks.when(IntegrationSelectorMock.selectByBatchId(batchIds)).thenReturn(intRequests);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(IntegrationSelectorMock);
        Application.UnitOfWork.setMock(mockUow);
        CooSameStoreServiceImpl cooService = new CooSameStoreServiceImpl();
        cooService.getIntegrationRequests(batchIds);
        cooService.reparentTheStore(intRequests, intIdToBusinessActId);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerDirty(fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                Integration_Request__c.sfdc_status__c => IR_STATUS_PROCESSED
            }
        ));
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerDirty(fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                Account.parentId => parentActId
            }
        ));

    }
    @isTest
    static void testWhenCompletedIntReqReceivedThenDeleteExistingPaymentAccountRelation() {
        Id intId = fflib_IDGenerator.generate(Integration_Request__c.SObjectType);
        Id accountId =  fflib_IDGenerator.generate(Account.SObjectType);
        Integration_Request__c integrationRequest = new Integration_Request__c(
            Id = intId,
            Account__C = accountId,
            sfdc_status__c = IR_STATUS_PENDING,
            Batch_Id__c = IR_BATCH_ID,
            Product_status__c = IR_PRODUCT_STATUS_COMPLETED,
            business_Id__c = '32323232',
            payload__c = mockPayloadData()
        );
        Id actPaymentRelationId = fflib_IDGenerator.generate(Account_Payment_Account_Relation__c.SObjectType);
        Account_Payment_Account_Relation__c actPaymentRelation = new Account_Payment_Account_Relation__c(
            Id = actPaymentRelationId,
            Account__c = accountId
        );
        List<Account_Payment_Account_Relation__c> actPaymentRelations = new List<Account_Payment_Account_Relation__c>{actPaymentRelation};
        List<Integration_Request__c> intRequests  = new List<Integration_Request__c>{integrationRequest};
        // Mock selector
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        IAccountPaymentAccountRelationsSelector actPaymentRelationMock = (IAccountPaymentAccountRelationsSelector) mocks.mock(IAccountPaymentAccountRelationsSelector.class);
        mocks.startStubbing();
        mocks.when(actPaymentRelationMock.SObjectType()).thenReturn(Account_Payment_Account_Relation__c.SObjectType);
        mocks.when(actPaymentRelationMock.selectByAccountIdsAndPaymentAccountRecordTypes(new Set<Id>{accountId}, PAYMENT_ACCOUNT_RECORD_TYPES)).thenReturn(actPaymentRelations);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(actPaymentRelationMock);
        Application.UnitOfWork.setMock(mockUow);
        CooSameStoreServiceImpl cooService = new CooSameStoreServiceImpl();
        cooService.deletePaymentAccountRelation(intRequests);
		((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerDeleted(fflib_Match.sObjectsWith(
            new List<Map<SObjectField, Object>>{
                new Map<SObjectField, Object>{
                    Account_Payment_Account_Relation__c.Id => actPaymentRelationId
                }
            }
        ));
     }

    @isTest
    static void testWhenReadyIntReqReceivedThenUpdatetheIntegrationRequestToProcessed() {
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Integration_Request__c parentIntReq = new Integration_Request__c(
            Id = fflib_IDGenerator.generate(Integration_Request__c.SObjectType),
            opportunity__c = opportunityId,
            sfdc_status__c = IR_STATUS_PROCESSED
        );
        Integration_Request__c integrationRequest1 = new Integration_Request__c(
            Id = fflib_IDGenerator.generate(Integration_Request__c.SObjectType),
            Parent_Integration_Request__r =  parentIntReq,
            Parent_Integration_Request__c = parentIntReq.Id,
            Account__C = fflib_IDGenerator.generate(Account.SObjectType),
            sfdc_status__c = IR_STATUS_PENDING,
            Batch_Id__c = IR_BATCH_ID,
            Product_status__c = IR_PRODUCT_STATUS_READY,
            business_Id__c = '32323232',
            payload__c = mockPayloadData()
        );
        List<Integration_Request__c> intReqByBatch = new List<Integration_Request__c>{
            integrationRequest1
        };
        Set<String> batchIds = new Set<String>{IR_BATCH_ID};
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        IIntegrationRequestsSelector integrationSelectorMock = (IIntegrationRequestsSelector) mocks.mock(IIntegrationRequestsSelector.class);
        mocks.startStubbing();
        mocks.when(IntegrationSelectorMock.SObjectType()).thenReturn(Integration_Request__c.SObjectType);
        mocks.when(IntegrationSelectorMock.selectByBatchId(batchIds)).thenReturn(intReqByBatch);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(IntegrationSelectorMock);
        Application.UnitOfWork.setMock(mockUow);
        CooSameStoreServiceImpl cooService = new CooSameStoreServiceImpl();
        cooService.getIntegrationRequests(batchIds);
        cooService.processReadyCooRequests(intReqByBatch);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerDirty(fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                Integration_Request__c.sfdc_status__c => IR_STATUS_PROCESSED
            }
        ));

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerDirty(fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                Account.POS_Integration_Type__c => 'adora'
            }
        ));
    }

     /**
     * @description Creates a mock coo payload
     * @return  A json payload.
     */
    public static String mockPayloadData(){
        return '{' +
            '"coo_event_type": "COO Event",' +
            '"changeOfownershipStrategy": "Change Ownership Strategy",' +
            '"storeChangeOfOwnershipOnboarding": {' +
            '"onboarding_id": "Onboarding001",' +
            '"business_id": "Business001",' +
            '"legal_business_name": "Test Business",' +
            '"store_id": "Store001",' +
            '"store_name": "Test Store",' +
            '"scheduled_cutoff_time": "2023-05-30 09:00:00",' +
            '"new_owner_first_name": "John",' +
            '"new_owner_last_name": "Doe",' +
            '"new_owner_email": "john.doe@example.com",' +
            '"new_owner_phone": "1234567890",' +
            '"requester_user_id": "User001",' +
            '"new_user_id": "User002",' +
            '"old_user_id": "User003",' +
            '"revoke_access": false,' +
            '"create_new_business": true,' +
            '"approved_at": "2023-05-30 10:00:00",' +
            '"approval_status": "",'+
            '"onboarding_status": "",'+
            '"payment_account_id": "Account001",' +
            '"pactsafe_activity_id": "Activity001",' +
            '"batch_request_id": "Batch001",' +
            '"additionalfields": {' +
            '"notes": "Test notes",' +
            '"order_protocol": "POINT_OF_SALE",' +
            '"pos_provider_type": "",' +
            '"pos_provider_type_str": "adora",' +
            '"is_franchise": false,' +
            '"should_ship_tablet": true,' +
            '"legal_business_address": {' +
            '"street": "123 Main St",' +
            '"city": "Test City",' +
            '"postal_code": "12345",' +
            '"country": "US",' +
            '"state": "TX",' +
            '"owner_phone": "1234567890"' +
            '}' +
            '},' +
            '"new_user": [' +
            '{"email": "newuser@example.com",' +
            '"first_name": "James",' +
            '"last_name": "two",' +
            '"phone": "9876543210",' +
            '"SSN": "123-45-6789"}'+
            '],'+
            '"business_address_id": "Address001",' +
            '"geo_address": {'+
            '"street": "12006 corsicana",'+
            '"city": "Manor",'+
            '"zipCode": "78653",'+
            '"countryShortname": "US",'+
            '"administrativeAreaLevel1": "TX"'+
            '}'+
            '}' +
            '}';
   }
}