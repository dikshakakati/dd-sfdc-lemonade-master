/**
 * @author DoorDash
 * @date 03/21/2023
 * @description Test class for IntegrationRequests class.
 */
@isTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts, PMD.NcssTypeCount')
public class IntegrationRequestsTest {
    private static final String ASSERT_MESSAGE_ACCOUNT_ID_NOT_MATCHING = 'Unexpected result: Updated Account Id not matching.';
    private static final String ASSERT_MESSAGE_UPDATED_RECORD_NOT_MATCHING = 'Unexpected result: Updated record count not matching.';
    private static final String PROCESS_NEW_POS_INTEGRATION_REQUEST = 'PROCESS_NEW_POS_INTEGRATION_REQUEST';
    private static final String PROCESS_UPDATE_POS_INTEGRATION_REQUEST = 'PROCESS_UPDATE_POS_INTEGRATION_REQUEST';
    private static final String PROCESS_NEW_POS_INTEGRATION_REQUEST_CHUNK_SIZE_SETTING = 'ProcessNewPosIrChunkSize';
    private static final String PROCESS_UPDATE_POS_INTEGRATION_REQUEST_CHUNK_SIZE_SETTING = 'ProcessUpdatePosIrChunkSize';
    private static final String CONSTRUCTOR_ASSERT_MESSAGE = 'Unexpected result: The objects are matching';
    private static final String SFDC_ORG_NOT_MATCHING_MESSAGE = 'sfdc org not matching';
    private static final string SFDC_ORG_LEMONADE = 'Lemonade';
    private static final string SFDC_ORG_FIGMENT = 'Figment';
    private static final string ACTION_UPDATE = 'UPDATE';
    private static final string INTEGRATION_TYPE_POS = 'POS Requests';
    private static final string STORE_ID = '24680';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String METADATA_VALUE = '3';
    private static final string MOCK_BUSINESS_ID = '13346';
    private static final String INTEGRATION_TYPE_COO_SAME_STORE = 'COO Same Store';
    private static final String INTEGRATION_TYPE_PLACE_IT_FOR_ME = 'Place It For Me';
    private static final String PRODUCT_STATUS_CREATED = 'created';
    private static final String PRODUCT_STATUS_APPROVED = 'approved';
    private static final String PRODUCT_STATUS_COMPLETED = 'completed';
    private static final String PRODUCT_STATUS_CANCELLED = 'cancelled ';
    private static final String PRODUCT_STATUS_READY = 'ready';
    private static final String SFDC_STATUS_PROCESSED = 'Processed';
    /**
     * @description To test class instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<Integration_Request__c> integrationRequestList = new List<Integration_Request__c>();
        IntegrationRequests.newInstance(integrationRequestList);
        IntegrationRequests integrationRequestsObject = new IntegrationRequests(
            integrationRequestList
        );
        IntegrationRequests.Constructor constructorObject = new IntegrationRequests.Constructor();
        constructorObject.construct(integrationRequestList);
        System.assertNotEquals(
            IntegrationRequests.newInstance(integrationRequestList),
            integrationRequestsObject,
            CONSTRUCTOR_ASSERT_MESSAGE
        );
    }
    @isTest
    private static void testWhenIntegrationRequestsReceivedThenValidateExistingStoreAndTransferToFigment() {
        Fake integrationRequestFakeInstace = ServiceMockDataBuilder.createIntegrationRequestFakeInstance(
                STORE_ID
            )
            .setField(Integration_Request__c.SFDC_Org__c, SFDC_ORG_LEMONADE)
            .setField(Integration_Request__c.Integration_Type__c, INTEGRATION_TYPE_POS);

        Integration_request__c integrationRequestInstance = (Integration_request__c) ServiceMockDataBuilder.convertToSObject(
            integrationRequestFakeInstace
        );
        IntegrationRequests.newInstance(
                new List<Integration_Request__c>{ integrationRequestInstance }
            )
            .validateAndPrePopulateFields();

        System.assertEquals(
            SFDC_ORG_FIGMENT,
            integrationRequestInstance.SFDC_Org__c,
            SFDC_ORG_NOT_MATCHING_MESSAGE
        );
    }
    @isTest
    private static void testWhenCooIntReqReceivedThenPrePopulateFields() {
        Fake integrationRequestFakeInstace = ServiceMockDataBuilder.createIntegrationRequestFakeInstance(
                STORE_ID
            )
            .setField(Integration_Request__c.SFDC_Org__c, SFDC_ORG_LEMONADE)
            .setField(Integration_Request__c.Integration_Type__c, INTEGRATION_TYPE_COO_SAME_STORE)
            .setField(Integration_Request__c.Product_status__c, PRODUCT_STATUS_APPROVED);

        Integration_request__c integrationRequestInstance = (Integration_request__c) ServiceMockDataBuilder.convertToSObject(
            integrationRequestFakeInstace
        );
        IntegrationRequests.newInstance(
                new List<Integration_Request__c>{ integrationRequestInstance }
            )
            .validateAndPrePopulateFields();

        System.assertEquals(
            SFDC_STATUS_PROCESSED,
            integrationRequestInstance.Sfdc_status__c,
            'sfdc status not matching'
        );
    }

    private void testWhenIntegrationRequestReceivedThenValidateAndPrepopulate() {
        // Create test data: Integration Requests
        List<Integration_request__c> integrationRequestList = new List<Integration_request__c>();
        Integration_request__c integrationRequest1 = new Integration_request__c(
            Store_Id__c = 'Store001',
            Integration_Type__c = 'POS Requests'
        );
        Integration_request__c integrationRequest2 = new Integration_request__c(
            Store_Id__c = 'Store002',
            Integration_Type__c = 'POS Requests'
        );
        Integration_request__c integrationRequest3 = new Integration_request__c(
            Store_Id__c = 'Store003',
            Integration_Type__c = 'COO Same Store',
            Onboarding_Id__c = 'Onboarding003'
        );
        integrationRequestList.add(integrationRequest1);
        integrationRequestList.add(integrationRequest2);
        integrationRequestList.add(integrationRequest3);

        // Create test data: Xrefs
        List<Xref__c> xrefList = new List<Xref__c>();
        Id accountId1 = fflib_IDGenerator.generate(Account.SObjectType);
        Id accountId2 = fflib_IDGenerator.generate(Account.SObjectType);
        Xref__c xref1 = new Xref__c(
            Id = fflib_IDGenerator.generate(Xref__c.SObjectType),
            External_ID__c = 'Store001',
            Salesforce_Account_Name__c = accountId1
        );
        Xref__c xref3 = new Xref__c(
            Id = fflib_IDGenerator.generate(Xref__c.SObjectType),
            External_ID__c = 'Store003',
            Salesforce_Account_Name__c = accountId2
        );
        xrefList.add(xref1);
        xrefList.add(xref3);

        // Create test data: Onboarding Integration Requests
        List<Integration_request__c> onboardingIntegrationRequestList = new List<Integration_request__c>();
        Integration_request__c onboardingIntegrationRequest1 = new Integration_request__c(
            Id = fflib_IDGenerator.generate(Integration_request__c.SObjectType),
            Onboarding_Id__c = 'Onboarding003'
        );
        onboardingIntegrationRequestList.add(onboardingIntegrationRequest1);

        // Set up the selector mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IntegrationRequestsSelector integrationRequestsSelectorMock = (IntegrationRequestsSelector) mocks.mock(
            IntegrationRequestsSelector.class
        );
        mocks.startStubbing();
        mocks.when(
                xrefSelectorMock.selectXrefsByBusinessReferenceExternalIdOrStoreIds(
                    new Set<String>{ 'Store001', 'Store003' }
                )
            )
            .thenReturn(xrefList);
        mocks.when(
                integrationRequestsSelectorMock.selectParentByOnboardingId(
                    new Set<String>{ 'Onboarding001', 'Onboarding003' }
                )
            )
            .thenReturn(onboardingIntegrationRequestList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(xrefSelectorMock);
        Application.SELECTOR.setMock(integrationRequestsSelectorMock);

        // Instantiate the domain class
        IIntegrationRequests integrationRequests = IntegrationRequests.newInstance(
            integrationRequestList
        );

        // Call the method under test
        Test.startTest();
        integrationRequests.validateAndPrePopulateFields();
        Test.stopTest();

        // Assert the updated integration requests
        List<Integration_request__c> updatedRequests = (List<Integration_request__c>) integrationRequests.getRecords();
        System.assertEquals(3, updatedRequests.size(), 'Integration requests size not matching');

        // Assert the field values of the updated requests
        for (Integration_request__c request : updatedRequests) {
            if (request.Store_Id__c == 'Store001') {
                System.assertEquals(accountId1, request.Account__c, 'Account Id not matching');
                System.assertEquals('Lemonade', request.SFDC_Org__c, 'Sfdc org value not mathcing');
                System.assertEquals(
                    null,
                    request.Parent_Integration_Request__c,
                    'Parent integration expected as null'
                );
            } else if (request.Store_Id__c == 'Store002') {
                System.assertEquals('Figment', request.SFDC_Org__c, 'Org value not matching');
                System.assertEquals(
                    null,
                    request.Parent_Integration_Request__c,
                    'parent integration request expected as nu;;'
                );
            } else if (request.Store_Id__c == 'Store003') {
                System.assertEquals(accountId2, request.Account__c, 'Account id not matching');
                System.assertEquals(
                    onboardingIntegrationRequestList[0].Id,
                    request.Parent_Integration_Request__c,
                    'Parent integration Id not matching'
                );
            }
        }
    }
    @isTest
    private static void testWhenFilterByProductStatusThenReturnFilteredIntegrationRequests() {
        // Create test data
        List<Integration_Request__c> integrationRequestList = new List<Integration_Request__c>();
        Integration_request__c integrationRequest1 = new Integration_request__c(
            Product_Status__c = 'approved'
        );
        Integration_request__c integrationRequest2 = new Integration_request__c(
            Product_Status__c = 'completed'
        );
        Integration_request__c integrationRequest3 = new Integration_request__c(
            Product_Status__c = 'cancelled'
        );
        integrationRequestList.add(integrationRequest1);
        integrationRequestList.add(integrationRequest2);
        integrationRequestList.add(integrationRequest3);

        // Instantiate the domain class
        IIntegrationRequests integrationRequests = IntegrationRequests.newInstance(
            integrationRequestList
        );

        // Filter by product status
        IIntegrationRequests filteredRequests = integrationRequests.filterByProductStatus(
            'approved'
        );

        // Assert the filtered requests
        System.assertEquals(
            1,
            filteredRequests.getRecords().size(),
            'Integration request size not matching'
        );
        List<Integration_request__c> filteredList = (List<Integration_request__c>) filteredRequests.getRecords();
        System.assertEquals(
            integrationRequest1,
            filteredList[0],
            'Integration request list not matching.'
        );
    }
    @isTest
    private static void testWhenFilterBySfdcStatusThenReturnFilteredIntegrationRequests() {
        // Create test data
        List<Integration_Request__c> integrationRequestList = new List<Integration_Request__c>();
        Integration_request__c integrationRequest1 = new Integration_request__c(
            SFDC_Status__c = 'Processed'
        );
        Integration_request__c integrationRequest2 = new Integration_request__c(
            SFDC_Status__c = 'Failed'
        );
        Integration_request__c integrationRequest3 = new Integration_request__c(
            SFDC_Status__c = 'New'
        );
        integrationRequestList.add(integrationRequest1);
        integrationRequestList.add(integrationRequest2);
        integrationRequestList.add(integrationRequest3);

        // Instantiate the domain class
        IIntegrationRequests integrationRequests = IntegrationRequests.newInstance(
            integrationRequestList
        );

        // Filter by SFDC status
        IIntegrationRequests filteredRequests = integrationRequests.filterBySfdcStatus('Processed');

        // Assert the filtered requests

        System.assertEquals(
            1,
            filteredRequests.getRecords().size(),
            'Int request size not matching'
        );
        List<Integration_request__c> filteredList = (List<Integration_request__c>) filteredRequests.getRecords();
        System.assertEquals(integrationRequest1, filteredList[0], 'Int request not matching');
    }
    @isTest
    private static void testWhenGetStoreIdsThenReturnSetOfStoreIds() {
        // Create test data
        List<Integration_Request__c> integrationRequestList = new List<Integration_Request__c>();
        Integration_request__c integrationRequest1 = new Integration_request__c(
            Store_Id__c = '12345'
        );
        Integration_request__c integrationRequest2 = new Integration_request__c(
            Store_Id__c = '67890'
        );
        Integration_request__c integrationRequest3 = new Integration_request__c(
            Store_Id__c = '24680'
        );
        integrationRequestList.add(integrationRequest1);
        integrationRequestList.add(integrationRequest2);
        integrationRequestList.add(integrationRequest3);

        // Instantiate the domain class
        IIntegrationRequests integrationRequests = IntegrationRequests.newInstance(
            integrationRequestList
        );

        // Get store IDs
        Set<String> storeIds = integrationRequests.getStoreIds();

        // Assert the store IDs
        Set<String> expectedStoreIds = new Set<String>{ '12345', '67890', '24680' };

        System.assertEquals(expectedStoreIds, storeIds, 'Excepted store Ids are not matching');
    }
    @isTest
    private static void testWhenGetBusinessIdsThenReturnSetOfBusinessIds() {
        // Create test data
        List<Integration_Request__c> integrationRequestList = new List<Integration_Request__c>();
        Integration_request__c integrationRequest1 = new Integration_request__c(
            Business_Id__c = 'B100'
        );
        Integration_request__c integrationRequest2 = new Integration_request__c(
            Business_Id__c = 'B200'
        );
        Integration_request__c integrationRequest3 = new Integration_request__c(
            Business_Id__c = 'B300'
        );
        integrationRequestList.add(integrationRequest1);
        integrationRequestList.add(integrationRequest2);
        integrationRequestList.add(integrationRequest3);

        // Instantiate the domain class
        IIntegrationRequests integrationRequests = IntegrationRequests.newInstance(
            integrationRequestList
        );

        // Get business IDs
        Set<String> businessIds = integrationRequests.getBusinessIds();

        // Assert the business IDs
        Set<String> expectedBusinessIds = new Set<String>{ 'B100', 'B200', 'B300' };
        System.assertEquals(expectedBusinessIds, businessIds, 'Business Ids are not matching');
    }

    @isTest
    private static void testWhenFilterBatchIdsIrNotInProductStatusThenReturnBatchIds() {
        // Create test data
        List<Integration_Request__c> integrationRequestList = new List<Integration_Request__c>();
        Integration_request__c integrationRequest1 = new Integration_request__c(
            Product_Status__c = 'approved',
            Onboarding_Id__c = 'O100',
            Batch_Id__c = 'B100'
        );
        Integration_request__c integrationRequest2 = new Integration_request__c(
            Product_Status__c = 'completed',
            Onboarding_Id__c = 'O200',
            Batch_Id__c = 'B200'
        );
        Integration_request__c integrationRequest3 = new Integration_request__c(
            Product_Status__c = 'cancelled',
            Onboarding_Id__c = 'O300',
            Batch_Id__c = 'B300'
        );
        integrationRequestList.add(integrationRequest1);
        integrationRequestList.add(integrationRequest2);
        integrationRequestList.add(integrationRequest3);

        // Instantiate the domain class
        IIntegrationRequests integrationRequests = IntegrationRequests.newInstance(
            integrationRequestList
        );

        // Filter batch IDs
        Set<String> batchIds = integrationRequests.filterBatchIdsIrNotInProductStatus(
            new Set<String>{ 'approved', 'completed' }
        );

        // Assert the batch IDs
        Set<String> expectedBatchIds = new Set<String>{ 'B300' };
        System.assertEquals(expectedBatchIds, batchIds, 'Batch Ids are not matching');
    }
    private static Xref__c createXrefFakeInstance(String storeAccountId) {
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        return new Xref__c(
            Id = xrefId,
            Salesforce_Account_Name__c = storeAccountId,
            External_ID__c = STORE_ID
        );
    }
    private static Fake createParentAccount() {
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        return parentAccountFakeInstance;
    }
    private static Fake createChildAccountInstance(
        Id businessAccountId,
        Fake parentAccountFakeInstance
    ) {
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccountId,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.ParentId, businessAccountId)
            .setField(Account.Order_Protocol__c, null)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent('Parent', parentAccountFakeInstance);
        return childAccountFakeInstance;
    }

    /**
     * @description It is used to createLog when Integration Requests are passed.
     */
    @isTest
    private static void testWhenIntegrationRequestsReceivedThenCreateLog() {
        Fake integrationRequestFakeInstace = ServiceMockDataBuilder.createIntegrationRequestFakeInstance(
                STORE_ID
            )
            .setField(Integration_Request__c.SFDC_Org__c, SFDC_ORG_LEMONADE)
            .setField(Integration_Request__c.Integration_Type__c, INTEGRATION_TYPE_POS);

        Integration_request__c integrationRequestInstance = (Integration_request__c) ServiceMockDataBuilder.convertToSObject(
            integrationRequestFakeInstace
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        IntegrationRequests.createLog(
            new List<Integration_Request__c>{ integrationRequestInstance }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        System.assertEquals(
            SFDC_ORG_LEMONADE,
            integrationRequestInstance.SFDC_Org__c,
            SFDC_ORG_NOT_MATCHING_MESSAGE
        );
    }

    /**
     * @description To test Business Account is associated to the Integration Request
     * when Integration Requests created for 'Place It For Me' process with Business Id.
     */
    @isTest
    private static void testWhenPlaceItForMeIntegrationRequestReceivedThenPopulateBusinessAccount() {
        List<Integration_request__c> newIntegrationRequests = new List<Integration_request__c>();
        Integration_request__c newIntegrationRequest = new Integration_request__c(
            Business_Id__c = MOCK_BUSINESS_ID,
            Integration_Type__c = INTEGRATION_TYPE_PLACE_IT_FOR_ME
        );
        newIntegrationRequests.add(newIntegrationRequest);
        List<Xref__c> newXrefs = new List<Xref__c>();
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Xref__c mockXref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, fflib_IDGenerator.generate(Xref__c.SObjectType))
            .setField(Xref__c.External_ID__c, MOCK_BUSINESS_ID)
            .setField(Xref__c.Salesforce_Account_Name__c, accountId)
            .setField(Xref__c.BusinessID__c, MOCK_BUSINESS_ID)
            .setField(Xref__c.Account_Record_Type__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(
                'Business_Reference__r',
                new Fake(Business_Reference__c.class)
                    .setField(Business_Reference__c.External_Id__c, MOCK_BUSINESS_ID)
            )
            .toSObject();
        newXrefs.add(mockXref);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(xrefSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                xrefSelectorMock.selectXrefsByBusinessReferenceExternalIdOrStoreIds(
                    new Set<String>{ MOCK_BUSINESS_ID }
                )
            )
            .thenReturn(newXrefs);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(xrefSelectorMock);
        IIntegrationRequests integrationRequests = IntegrationRequests.newInstance(
            newIntegrationRequests
        );
        Test.startTest();
        integrationRequests.validateAndPrePopulateFields();
        Test.stopTest();
        System.assertEquals(
            1,
            newIntegrationRequests.size(),
            ASSERT_MESSAGE_UPDATED_RECORD_NOT_MATCHING
        );
        System.assertEquals(
            accountId,
            newIntegrationRequests[0].Account__c,
            ASSERT_MESSAGE_ACCOUNT_ID_NOT_MATCHING
        );
    }
}