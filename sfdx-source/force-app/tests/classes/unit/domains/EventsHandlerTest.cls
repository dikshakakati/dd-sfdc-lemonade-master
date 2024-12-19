/**
 * @description Event Object Trigger Handler Test.
 * @author Deloitte
 * @date 05/01/2024
 */
@isTest(SeeAllData=false)
public class EventsHandlerTest {
    private static final Date AFTERTENDAYS = System.today().addDays(10);
    private static final String EVENT_MISSED = 'Event Missed';
    private static final String SALES_DEVELOPMENT_REP_ROLE = 'Sales Development Rep';
    private static final String PROSPECTING = 'Prospecting';
    private static final String UNEXPECTED_ERROR = 'UnExpected result: Both constructs are similar.';
    private static final String LEAD_NAME = 'Test Lead Name';

    /**
     * @description This method is used to test Event TriggerHandler.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheck() {
        List<Event> newEvent = new List<Event>();
        EventsHandler eventObject = new EventsHandler(newEvent);
        EventsHandler.Constructor objConstructor = new EventsHandler.Constructor();
        objConstructor.construct(newEvent);
        System.assertNotEquals(eventObject, objConstructor.construct(newEvent), UNEXPECTED_ERROR);
    }

    /**
     * @description To test updateMeetingSetOnLeadAndOpportunity method call on Event insert
     * JIRA# LEM-21484
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenFutureMeetingInsertThenUpdateMeetingSetOnLeadAndOpportunity() {
        Id opportunityId = Fake.generateId(Opportunity.class);
        Opportunity opportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.StageName, PROSPECTING)
            .setField(Opportunity.CloseDate, Date.today())
            .toSObject();

        Id eventId = Fake.generateId(Event.class);
        List<Event> newEvents = new List<Event>();
        Event newEvent = (Event) new Fake(Event.class)
            .setField(Event.Id, eventId)
            .setField(Event.DurationInMinutes, 10)
            .setField(Event.WhatId, opportunityId)
            .setField(Event.ActivityDateTime, AFTERTENDAYS)
            .toSObject();
        newEvents.add(newEvent);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IEvents eventMock = (IEvents) mocks.mock(IEvents.class);
        mocks.startStubbing();
        mocks.when(eventMock.getType()).thenReturn(Schema.Event.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(eventMock);
        fflib_SObjectDomain.Test.Database.onInsert(newEvents);
        fflib_SObjectDomain.triggerHandler(EventsHandler.class);
        ((IEvents) mocks.verify(eventMock, 1)).updateMeetingSetOnLeadAndOpportunity();
    }

    /**
     * @description To test when Event is deleted then update Meeting Set field on Lead and Opportunity.
     * JIRA# LEM-21484
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenEventDeletedThenUpdateMeetingSetOnLeadAndOpportunity() {
        Id opportunityId = Fake.generateId(Opportunity.class);
        Opportunity opportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.StageName, PROSPECTING)
            .setField(Opportunity.CloseDate, Date.today())
            .toSObject();

        Id eventId = Fake.generateId(Event.class);
        List<Event> deletedEvents = new List<Event>();
        Event newEvent = (Event) new Fake(Event.class)
            .setField(Event.Id, eventId)
            .setField(Event.DurationInMinutes, 10)
            .setField(Event.WhatId, opportunityId)
            .setField(Event.ActivityDateTime, AFTERTENDAYS)
            .toSObject();
        deletedEvents.add(newEvent);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IEvents eventMock = (IEvents) mocks.mock(IEvents.class);
        mocks.startStubbing();
        mocks.when(eventMock.getType()).thenReturn(Schema.Event.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(eventMock);
        fflib_SObjectDomain.Test.Database.onDelete(
            new Map<ID, Event>{ deletedEvents[0].Id => deletedEvents[0] }
        );
        fflib_SObjectDomain.triggerHandler(EventsHandler.class);
        ((IEvents) mocks.verify(eventMock, 1))
            .updateMeetingSetOnLeadAndOpportunityOnEventStartDateUpdate();
    }

    /**
     * @description To test updateFirstAndLastQualifiedActivityOnLead method call on Event insert
     * JIRA# LEM-21484
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenFutureMeetingInsertThenUpdateFirstAndLastQualifiedActivityOnLead() {
        Id leadId = Fake.generateId(Lead.class);
        Lead lead = (Lead) new Fake(Lead.class)
            .setField(Lead.Id, leadId)
            .setField(Lead.LastName, LEAD_NAME)
            .setField(Lead.Phone, '1234567899')
            .toSObject();

        Id eventId = Fake.generateId(Event.class);
        List<Event> newEvents = new List<Event>();
        Event newEvent = (Event) new Fake(Event.class)
            .setField(Event.Id, eventId)
            .setField(Event.DurationInMinutes, 10)
            .setField(Event.WhoId, leadId)
            .setField(Event.ActivityDateTime, AFTERTENDAYS)
            .toSObject();
        newEvents.add(newEvent);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IEvents eventMock = (IEvents) mocks.mock(IEvents.class);
        mocks.startStubbing();
        mocks.when(eventMock.getType()).thenReturn(Schema.Event.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(eventMock);
        fflib_SObjectDomain.Test.Database.onInsert(newEvents);
        fflib_SObjectDomain.triggerHandler(EventsHandler.class);
        ((IEvents) mocks.verify(eventMock, 1))
            .updateFirstAndLastQualifiedActivityOnLeadAndOpportunity();
    }

    /**
     * @description To test method call on Event insert
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenEventMeetingMissedInsertThenUpdateSDRTouchOnOpportunity() {
        Id opportunityId = Fake.generateId(Opportunity.class);
        Opportunity opportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.StageName, PROSPECTING)
            .setField(Opportunity.CloseDate, Date.today())
            .toSObject();
        OpportunityTeamMember opportunityTeamMember = (OpportunityTeamMember) new Fake(
                OpportunityTeamMember.class
            )
            .setField(opportunityTeamMember.OpportunityId, opportunityId)
            .setField(opportunityTeamMember.TeamMemberRole, SALES_DEVELOPMENT_REP_ROLE)
            .setField(opportunityTeamMember.UserId, UserInfo.getUserID())
            .toSObject();

        Id eventId = Fake.generateId(Event.class);
        List<Event> newEvents = new List<Event>();
        Event newEvent = (Event) new Fake(Event.class)
            .setField(Event.Id, eventId)
            .setField(Event.DurationInMinutes, 10)
            .setField(Event.WhatId, opportunityId)
            .setField(Event.ActivityDateTime, AFTERTENDAYS)
            .toSObject();
        newEvents.add(newEvent);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IEvents eventMock = (IEvents) mocks.mock(IEvents.class);
        mocks.startStubbing();
        mocks.when(eventMock.getType()).thenReturn(Schema.Event.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(eventMock);
        fflib_SObjectDomain.Test.Database.onInsert(newEvents);
        fflib_SObjectDomain.triggerHandler(EventsHandler.class);
        ((IEvents) mocks.verify(eventMock, 1)).updateSDRTouchOnOpportunity();
    }
    /**
     * @description To test method call on Event update
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenEventMeetingMissedUpdateThenUpdateSDRTouchOnOpportunity() {
        Id opportunityId = Fake.generateId(Opportunity.class);
        Opportunity opportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.StageName, PROSPECTING)
            .setField(Opportunity.CloseDate, Date.today())
            .toSObject();
        OpportunityTeamMember opportunityTeamMember = (OpportunityTeamMember) new Fake(
                OpportunityTeamMember.class
            )
            .setField(opportunityTeamMember.OpportunityId, opportunityId)
            .setField(opportunityTeamMember.TeamMemberRole, SALES_DEVELOPMENT_REP_ROLE)
            .setField(opportunityTeamMember.UserId, UserInfo.getUserID())
            .toSObject();

        Id eventId = Fake.generateId(Event.class);
        List<Event> oldEvents = new List<Event>();
        Event oldEvent = (Event) new Fake(Event.class)
            .setField(Event.Id, eventId)
            .setField(Event.DurationInMinutes, 10)
            .setField(Event.WhatId, opportunityId)
            .setField(Event.ActivityDateTime, AFTERTENDAYS)
            .setField(Event.Event_Status__c, '')
            .toSObject();
        oldEvents.add(oldEvent);

        List<Event> newEvents = new List<Event>();
        Event newEvent = (Event) new Fake(Event.class)
            .setField(Event.Id, eventId)
            .setField(Event.DurationInMinutes, 10)
            .setField(Event.WhatId, opportunityId)
            .setField(Event.ActivityDateTime, AFTERTENDAYS)
            .setField(Event.Event_Status__c, EVENT_MISSED)
            .toSObject();
        newEvents.add(newEvent);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IEvents eventMock = (IEvents) mocks.mock(IEvents.class);
        mocks.startStubbing();
        mocks.when(eventMock.getType()).thenReturn(Schema.Event.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(eventMock);
        fflib_SObjectDomain.Test.Database.onUpdate(newEvents, new Map<Id, SObject>(oldEvents));
        fflib_SObjectDomain.triggerHandler(EventsHandler.class);
        ((IEvents) mocks.verify(eventMock, 1)).updateSDRTouchOnOpportunity();
    }
}