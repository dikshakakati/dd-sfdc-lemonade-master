/**
 * @author Deloitte
 * @date 10/12/2022
 * @description Test class for OpportunityChangeEvents domain class.
 */
@isTest(SeeAllData=false)
private class OpportunityChangeEventsTest {
    private static final String CHANGE_TYPE_CREATE = 'CREATE';
    private static final String CHANGE_TYPE_UPDATE = 'UPDATE';
    private static final String CONSTRUCTOR_ASSERT_MESSAGE = 'Unexpected result: The objects are not matching';
    private static final List<String> NINTEX_FRANCHISE_AMENDMENT_FIELDS = new List<String>{
        'Nintex_Signed_Date__c'
    };
    private static final String NINTEX_USE_CASE_NEW_FRANCHISE = 'New Franchise - Unknown';
    private static final String NINTEX_USE_CASE_SSMO = 'SSMO';
    private static final String OPPORTUNITY_ACCOUNT_FIELD_API_NAME = 'AccountId';
    private static final String OPPORTUNITY_CONTRACT_FIELD_API_NAME = 'ContractId';
    private static final String OPPORTUNITY_MARKETPLACE_NINTEX_ID = 'OpportunityChangeEventsTestMarketplaceNintexId';
    private static final String OPPORTUNITY_MARKETPLACE_NINTEX_ID_FIELD_API_NAME = 'Marketplace_Nintex_Id__c';
    private static final String OPPORTUNITY_NAME = 'Test Opportunity';
    private static final String OPPORTUNITY_SOURCE = 'Nintex';
    private static final String OPPORTUNITY_STAGE_CLOSED_WON = 'Closed Won';
    private static final String OPPORTUNITY_STAGE_PROSPECTING = 'Prospecting';
    private static final String STAGENAME_FIELD = 'StageName';

    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<OpportunityChangeEvent> opportunityChangeEventsList = new List<OpportunityChangeEvent>();
        OpportunityChangeEvents.newInstance(opportunityChangeEventsList);
        OpportunityChangeEvents opportunityChangeEventsObject = new OpportunityChangeEvents(
            opportunityChangeEventsList
        );
        OpportunityChangeEvents.Constructor constructorObject = new OpportunityChangeEvents.Constructor();
        constructorObject.construct(opportunityChangeEventsList);
        System.assertNotEquals(
            OpportunityChangeEvents.newInstance(opportunityChangeEventsList),
            opportunityChangeEventsObject,
            CONSTRUCTOR_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test Opportunity Ids are collected and sent to OpportunitiesService class
     * for further processing on create change event type.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunityCreatedThenOpportunityIdsPassedToServices() {
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Set<Id> opportunityIds = new Set<Id>{ opportunityId };
        Fake opportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.AccountId, fflib_IDGenerator.generate(Account.SObjectType))
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING);
        Opportunity opportunity = (Opportunity) opportunityFakeInstance.toSObject();
        EventBus.ChangeEventHeader mockHeader = new EventBus.ChangeEventHeader();
        mockHeader.changeType = CHANGE_TYPE_CREATE;
        mockHeader.recordIds = new List<Id>{ opportunityId };
        List<OpportunityChangeEvent> mockOpportunityChangeEvents = new List<OpportunityChangeEvent>{
            new OpportunityChangeEvent(
                ChangeEventHeader = mockHeader,
                StageName = OPPORTUNITY_STAGE_CLOSED_WON
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunitiesService mockOpportunitiesService = (IOpportunitiesService) mocks.mock(
            IOpportunitiesService.class
        );
        Application.Service.setMock(IOpportunitiesService.class, mockOpportunitiesService);
        OpportunityChangeEvents.newInstance(mockOpportunityChangeEvents)
            .createParentWorkOrderOnNintexFormSubmission();
        ((IOpportunitiesService) mocks.verify(mockOpportunitiesService, 1))
            .initiateParentWorkOrdersCreation(opportunityIds);
        ((IOpportunitiesService) mocks.verify(mockOpportunitiesService, 1))
            .updateStageToClosedByFranchiseAmendmentProcessByChangeEvent(opportunityIds, true);
        ((IOpportunitiesService) mocks.verify(mockOpportunitiesService, 1))
            .activateBannerOnClosedWonRateChangeOpportunities(opportunityIds);
        ((IOpportunitiesService) mocks.verify(mockOpportunitiesService, 1))
            .initiateChildWorkOrdersCreationByNintexUseCase(opportunityIds);
    }

    /**
     * @description To test parent Work Order creation process is initiated
     * when Marketplace Nintex Id field is updated.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMarketplaceNintexIdUpdatedThenParentWorkOrderCreationInitiated() {
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Set<Id> opportunityIds = new Set<Id>{ opportunityId };
        Fake opportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.AccountId, fflib_IDGenerator.generate(Account.SObjectType))
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Marketplace_Nintex_Id__c, OPPORTUNITY_MARKETPLACE_NINTEX_ID)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Nintex_Use_Case__c, NINTEX_USE_CASE_NEW_FRANCHISE)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING);
        Opportunity opportunity = (Opportunity) opportunityFakeInstance.toSObject();
        EventBus.ChangeEventHeader mockHeader = new EventBus.ChangeEventHeader();
        mockHeader.changeType = CHANGE_TYPE_UPDATE;
        mockHeader.recordIds = new List<Id>{ opportunityId };
        mockHeader.changedFields = new List<String>{
            OPPORTUNITY_MARKETPLACE_NINTEX_ID_FIELD_API_NAME
        };
        List<OpportunityChangeEvent> mockOpportunityChangeEvents = new List<OpportunityChangeEvent>{
            new OpportunityChangeEvent(ChangeEventHeader = mockHeader)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunitiesService mockOpportunitiesService = (IOpportunitiesService) mocks.mock(
            IOpportunitiesService.class
        );
        Application.Service.setMock(IOpportunitiesService.class, mockOpportunitiesService);
        OpportunityChangeEvents.newInstance(mockOpportunityChangeEvents)
            .createParentWorkOrderOnNintexFormSubmission();
        ((IOpportunitiesService) mocks.verify(mockOpportunitiesService, 1))
            .initiateParentWorkOrdersCreation(opportunityIds);
    }

    /**
     * @description To test Franchise Amendment process initiation
     * when opportunity 'Nintex_Signed_Date__c' field is updated.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenNintexSignedDateFieldUpdatedThenFranchiseAmendmentProcessInitiated() {
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Set<Id> opportunityIds = new Set<Id>{ opportunityId };
        Fake opportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.AccountId, fflib_IDGenerator.generate(Account.SObjectType))
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Nintex_Signed_Date__c, System.today())
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING);
        Opportunity opportunity = (Opportunity) opportunityFakeInstance.toSObject();
        EventBus.ChangeEventHeader mockHeader = new EventBus.ChangeEventHeader();
        mockHeader.changeType = CHANGE_TYPE_UPDATE;
        mockHeader.recordIds = new List<Id>{ opportunityId };
        mockHeader.changedFields = NINTEX_FRANCHISE_AMENDMENT_FIELDS;
        List<OpportunityChangeEvent> mockOpportunityChangeEvents = new List<OpportunityChangeEvent>{
            new OpportunityChangeEvent(ChangeEventHeader = mockHeader)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunitiesService mockOpportunitiesService = (IOpportunitiesService) mocks.mock(
            IOpportunitiesService.class
        );
        Application.Service.setMock(IOpportunitiesService.class, mockOpportunitiesService);
        OpportunityChangeEvents.newInstance(mockOpportunityChangeEvents)
            .createParentWorkOrderOnNintexFormSubmission();
        ((IOpportunitiesService) mocks.verify(mockOpportunitiesService, 1))
            .updateStageToClosedByFranchiseAmendmentProcessByChangeEvent(opportunityIds, false);
    }

    /**
     * @description To test existing Opportunity Account Relationship deletion is initiated
     * when Opportunity is reparented to a new Account.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenReparentedThenRelatedOpportunityAccountRelationshipsDeletionInitiated() {
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Set<String> opportunityIds = new Set<String>{ opportunityId };
        Fake opportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.AccountId, fflib_IDGenerator.generate(Account.SObjectType))
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING);
        Opportunity opportunity = (Opportunity) opportunityFakeInstance.toSObject();
        EventBus.ChangeEventHeader mockHeader = new EventBus.ChangeEventHeader();
        mockHeader.changeType = CHANGE_TYPE_UPDATE;
        mockHeader.recordIds = new List<Id>{ opportunityId };
        mockHeader.changedFields = new List<String>{ OPPORTUNITY_ACCOUNT_FIELD_API_NAME };
        List<OpportunityChangeEvent> mockOpportunityChangeEvents = new List<OpportunityChangeEvent>{
            new OpportunityChangeEvent(ChangeEventHeader = mockHeader)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunitiesService mockOpportunitiesService = (IOpportunitiesService) mocks.mock(
            IOpportunitiesService.class
        );
        Application.Service.setMock(IOpportunitiesService.class, mockOpportunitiesService);
        OpportunityChangeEvents.newInstance(mockOpportunityChangeEvents)
            .deleteRelatedOpportunityAccountRelationshipsOnOpportunityReparenting();
        ((IOpportunitiesService) mocks.verify(mockOpportunitiesService, 1))
            .deleteOpportunityAccountRelationships(opportunityIds);
    }

    /**
     * @description To test child Work Orders creation process is initiated
     * when StageName field is updated.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenStageNameUpdatedThenChildWorkOrdersCreationInitiated() {
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Set<Id> opportunityIds = new Set<Id>{ opportunityId };
        Fake opportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.AccountId, fflib_IDGenerator.generate(Account.SObjectType))
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Marketplace_Nintex_Id__c, OPPORTUNITY_MARKETPLACE_NINTEX_ID)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Nintex_Use_Case__c, NINTEX_USE_CASE_NEW_FRANCHISE)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_CLOSED_WON);
        Opportunity opportunity = (Opportunity) opportunityFakeInstance.toSObject();
        EventBus.ChangeEventHeader mockHeader = new EventBus.ChangeEventHeader();
        mockHeader.changeType = CHANGE_TYPE_UPDATE;
        mockHeader.recordIds = new List<Id>{ opportunityId };
        mockHeader.changedFields = new List<String>{ STAGENAME_FIELD };
        List<OpportunityChangeEvent> mockOpportunityChangeEvents = new List<OpportunityChangeEvent>{
            new OpportunityChangeEvent(ChangeEventHeader = mockHeader)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunitiesService mockOpportunitiesService = (IOpportunitiesService) mocks.mock(
            IOpportunitiesService.class
        );
        Application.Service.setMock(IOpportunitiesService.class, mockOpportunitiesService);
        Test.startTest();
        OpportunityChangeEvents.newInstance(mockOpportunityChangeEvents)
            .createParentWorkOrderOnNintexFormSubmission();
        Test.stopTest();
        ((IOpportunitiesService) mocks.verify(mockOpportunitiesService, 1))
            .activateBannerOnClosedWonRateChangeOpportunities(opportunityIds);
        ((IOpportunitiesService) mocks.verify(mockOpportunitiesService, 1))
            .initiateChildWorkOrdersCreationByNintexUseCase(opportunityIds);
    }

    /**
     * @description To test parent Work Order creation process is initiated
     * when ContractId field is updated.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContractIdUpdatedThenParentWorkOrderCreationInitiated() {
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Set<Id> opportunityIds = new Set<Id>{ opportunityId };
        Fake opportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.AccountId, fflib_IDGenerator.generate(Account.SObjectType))
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.ContractId, fflib_IDGenerator.generate(Contract.SObjectType))
            .setField(Opportunity.Marketplace_Nintex_Id__c, OPPORTUNITY_MARKETPLACE_NINTEX_ID)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Nintex_Use_Case__c, NINTEX_USE_CASE_SSMO)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING);
        Opportunity opportunity = (Opportunity) opportunityFakeInstance.toSObject();
        EventBus.ChangeEventHeader mockHeader = new EventBus.ChangeEventHeader();
        mockHeader.changeType = CHANGE_TYPE_UPDATE;
        mockHeader.recordIds = new List<Id>{ opportunityId };
        mockHeader.changedFields = new List<String>{ OPPORTUNITY_CONTRACT_FIELD_API_NAME };
        List<OpportunityChangeEvent> mockOpportunityChangeEvents = new List<OpportunityChangeEvent>{
            new OpportunityChangeEvent(ChangeEventHeader = mockHeader)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunitiesService mockOpportunitiesService = (IOpportunitiesService) mocks.mock(
            IOpportunitiesService.class
        );
        Application.Service.setMock(IOpportunitiesService.class, mockOpportunitiesService);
        Test.startTest();
        OpportunityChangeEvents.newInstance(mockOpportunityChangeEvents)
            .createParentWorkOrderOnNintexFormSubmission();
        Test.stopTest();
        ((IOpportunitiesService) mocks.verify(mockOpportunitiesService, 1))
            .initiateParentWorkOrdersCreation(opportunityIds);
    }
}