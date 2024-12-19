/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Test class for SObjectsStatusUpdateServiceImpl.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class SObjectsStatusUpdateServiceImplTest {
    private static final String OUT_FOR_SIGNATURE = 'Out for Signature';
    private static final String APPROVED = 'Approved';
    private static final String DRAFT = 'DRAFT';
    private static final String PROSPECTING = 'Prospecting';
    private static final String OPPORTUNITY_NAME = 'Mock Opportunity Test';
    private static final String CLOSED_LOST = 'Closed Lost';
    private static final String CLOSED_WON = 'Closed Won';
    private static final String PROCESS_AUTOMATION_USER = 'Process Automation User';
    private static final String EVENT_TOPIC_UPDATE_IRONCLAD_WORKFLOW_TO_CANCELLED = 'EVENT_TOPIC_UPDATE_IRONCLAD_WORKFLOW_TO_CANCELLED';
    private static final String EVENT_TOPIC_MOCK = 'EVENT_TOPIC_MOCK';

    /**
     * @description It is used to test when Opportunity Stage is updated then associated sobject
     * status should be updated.
     */
    @isTest
    private static void testWhenOpportunityStageChangeThenUpdateRelatedSObjectsStatusFieldValue() {
        Id mockOpptyId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id mockQuoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id mockIronCladId = Fake.generateId(ironclad__Ironclad_Workflow__c.class);
        Fake mockOpportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, mockOpptyId)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.StageName, CLOSED_LOST)
            .setField(Opportunity.CloseDate, Date.today());
        ironclad__Ironclad_Workflow__c ironCladMock = (ironclad__Ironclad_Workflow__c) new Fake(
                ironclad__Ironclad_Workflow__c.class
            )
            .setField(ironclad__Ironclad_Workflow__c.Id, mockIronCladId)
            .setParent(
                'Quote__r',
                new Fake(SBQQ__Quote__c.class)
                    .setField(SBQQ__Quote__c.Id, mockQuoteId)
                    .setField(SBQQ__Quote__c.SBQQ__Status__c, OUT_FOR_SIGNATURE)
                    .setField(SBQQ__Quote__c.SBQQ__Primary__c, true)
                    .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, mockOpptyId)
                    .setParent('SBQQ__Opportunity2__r', mockOpportunityFakeInstance)
            )
            .toSObject();
        List<Opportunity> closedOpportunityList = new List<Opportunity>{
            new Opportunity(
                Id = ironCladMock.Quote__r.SBQQ__Opportunity2__c,
                StageName = CLOSED_LOST
            )
        };
        Map<String, String> chunkedPayloads = new Map<String, String>{
            EVENT_TOPIC_UPDATE_IRONCLAD_WORKFLOW_TO_CANCELLED => JSON.serialize(
                new Map<Id, ironclad__Ironclad_Workflow__c>(
                        new List<ironclad__Ironclad_Workflow__c>{ ironCladMock }
                    )
                    .keySet()
            )
        };
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = chunkedPayloads.get(EVENT_TOPIC_UPDATE_IRONCLAD_WORKFLOW_TO_CANCELLED),
            Topic__c = EVENT_TOPIC_UPDATE_IRONCLAD_WORKFLOW_TO_CANCELLED
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IIroncladWorkflowsSelector ironcladWorkflowsSelectorMock = (IIroncladWorkflowsSelector) mocks.mock(
            IIroncladWorkflowsSelector.class
        );
        INotifierEventsService mockNotifierEventsService = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        mocks.startStubbing();
        mocks.when(ironcladWorkflowsSelectorMock.sObjectType())
            .thenReturn(ironclad__Ironclad_Workflow__c.SObjectType);
        mocks.when(
                ironcladWorkflowsSelectorMock.selectIroncladWorkflowsWithOutForSignaturePrimaryQuotesByOpportunityIds(
                    new Set<Id>{ mockOpptyId }
                )
            )
            .thenReturn(new List<ironclad__Ironclad_Workflow__c>{ ironCladMock });
        mocks.stopStubbing();
        Application.SERVICE.setMock(INotifierEventsService.class, mockNotifierEventsService);
        Application.SELECTOR.setMock(ironcladWorkflowsSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        SObjectsStatusUpdateService.updateSObjectsStatusFieldValue(closedOpportunityList);
        SObjectsStatusUpdateService.execute(new List<Notifier__e>{ mockNotifierEvent });
        Test.stopTest();
        ((INotifierEventsService) mocks.verify(mockNotifierEventsService, 1))
            .publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_UPDATE_IRONCLAD_WORKFLOW_TO_CANCELLED => JSON.serialize(
                        new Map<Id, ironclad__Ironclad_Workflow__c>(
                                new List<ironclad__Ironclad_Workflow__c>{ ironCladMock }
                            )
                            .keySet()
                    )
                }
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description It is used to test when Opportunity stage is updated then associated sobject
     * status should not be updated.
     */
    @isTest
    private static void testWhenOpportunityStageChangedThenDoNotUpdateRelatedSObjectsStatusFieldValue() {
        Id mockOpptyId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id mockQuoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id mockIronCladId = Fake.generateId(ironclad__Ironclad_Workflow__c.class);
        Fake mockOpportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, mockOpptyId)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.StageName, CLOSED_WON)
            .setField(Opportunity.CloseDate, Date.today());
        ironclad__Ironclad_Workflow__c ironCladMock = (ironclad__Ironclad_Workflow__c) new Fake(
                ironclad__Ironclad_Workflow__c.class
            )
            .setField(ironclad__Ironclad_Workflow__c.Id, mockIronCladId)
            .setParent(
                'Quote__r',
                new Fake(SBQQ__Quote__c.class)
                    .setField(SBQQ__Quote__c.Id, mockQuoteId)
                    .setField(SBQQ__Quote__c.SBQQ__Status__c, OUT_FOR_SIGNATURE)
                    .setField(SBQQ__Quote__c.SBQQ__Primary__c, true)
                    .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, mockOpptyId)
                    .setParent('SBQQ__Opportunity2__r', mockOpportunityFakeInstance)
            )
            .toSObject();
        List<Opportunity> closedOpportunityList = new List<Opportunity>{
            new Opportunity(
                Id = ironCladMock.Quote__r.SBQQ__Opportunity2__c,
                StageName = CLOSED_LOST
            )
        };
        Map<String, String> chunkedPayloads = new Map<String, String>{
            EVENT_TOPIC_MOCK => JSON.serialize(
                new Map<Id, ironclad__Ironclad_Workflow__c>(
                        new List<ironclad__Ironclad_Workflow__c>{ ironCladMock }
                    )
                    .keySet()
            )
        };
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = chunkedPayloads.get(EVENT_TOPIC_MOCK),
            Topic__c = EVENT_TOPIC_MOCK
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IIroncladWorkflowsSelector ironcladWorkflowsSelectorMock = (IIroncladWorkflowsSelector) mocks.mock(
            IIroncladWorkflowsSelector.class
        );
        INotifierEventsService mockNotifierEventsService = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        mocks.startStubbing();
        mocks.when(ironcladWorkflowsSelectorMock.sObjectType())
            .thenReturn(ironclad__Ironclad_Workflow__c.SObjectType);
        mocks.when(
                ironcladWorkflowsSelectorMock.selectIroncladWorkflowsWithOutForSignaturePrimaryQuotesByOpportunityIds(
                    new Set<Id>{ mockOpptyId }
                )
            )
            .thenReturn(new List<ironclad__Ironclad_Workflow__c>{ ironCladMock });
        mocks.stopStubbing();
        Application.SERVICE.setMock(INotifierEventsService.class, mockNotifierEventsService);
        Application.SELECTOR.setMock(ironcladWorkflowsSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        SObjectsStatusUpdateService.updateSObjectsStatusFieldValue(closedOpportunityList);
        SObjectsStatusUpdateService.execute(new List<Notifier__e>{ mockNotifierEvent });
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }
}