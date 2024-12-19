/**
 * @author Deloitte
 * @date 06/17/2022
 * @description Test Class for Oportunity Change Events
 */
@isTest
private class OpportunityChangeEventsHandlerTest {
    /**
     * @description Test AccountRelationshipsHandler class on Relationship Insertion
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenChangeEventsAreCreatedThenCheckOpportunityReparenting() {
        List<OpportunityChangeEvent> changeEventRecords = new List<OpportunityChangeEvent>{
            new OpportunityChangeEvent()
        };
        fflib_SObjectDomain.Test.Database.onInsert(changeEventRecords);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunityChangeEvents eventsMock = (IOpportunityChangeEvents) mocks.mock(
            IOpportunityChangeEvents.class
        );
        mocks.startStubbing();
        mocks.when(eventsMock.getType()).thenReturn(OpportunityChangeEvent.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(eventsMock);

        fflib_SObjectDomain.triggerHandler(OpportunityChangeEventsHandler.class);
        ((IOpportunityChangeEvents) mocks.verify(eventsMock, 1))
            .deleteRelatedOpportunityAccountRelationshipsOnOpportunityReparenting();
    }

    /**
     * @description To test initiation of parent Work Order creation process
     * when Opportunity with Nintex Id is created/updated.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenChangeEventsCreatedThenCheckOpportunityWithChangedNintexId() {
        List<OpportunityChangeEvent> changeEvents = new List<OpportunityChangeEvent>{
            new OpportunityChangeEvent()
        };
        fflib_SObjectDomain.Test.Database.onInsert(changeEvents);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunityChangeEvents eventsMock = (IOpportunityChangeEvents) mocks.mock(
            IOpportunityChangeEvents.class
        );
        mocks.startStubbing();
        mocks.when(eventsMock.getType()).thenReturn(OpportunityChangeEvent.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(eventsMock);
        fflib_SObjectDomain.triggerHandler(OpportunityChangeEventsHandler.class);
        ((IOpportunityChangeEvents) mocks.verify(eventsMock, 1))
            .createParentWorkOrderOnNintexFormSubmission();
    }
}