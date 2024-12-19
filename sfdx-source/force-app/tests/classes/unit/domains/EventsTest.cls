/**
 * @description Event Domain class Test
 * @author Deloitte
 * @date 05/01/2024
 */
@isTest(SeeAllData=false)
public class EventsTest {
    private static final Date TODAY = Date.Today();
    private static final Date YESTERDAY = Date.Today() - 1;
    private static final Date AFTERTENDAYS = System.today().addDays(10);
    private static final Date AFTERFIVEDAYS = System.today().addDays(5);
    private static final Date CLOSE_DATE = System.today().addDays(-5);
    private static final String EVENT_MISSED = 'Event Missed';
    private static final String EVENT_HELD = 'Event Held';
    private static final String EVENT_SCHEDULED = 'Event Scheduled';
    private static final String EVENT_SUBJECT = 'Meeting';
    private static final String SALES_DEVELOPMENT_REP_ROLE = 'Sales Development Rep';
    private static final String SDR_NOT_MATCHING = 'Unexpected Error: SDR value is not matching.';
    private static final String UNEXPECTED_ERROR = 'UnExpected result: Both constructs are similar.';
    private static final String PROSPECTING = 'Prospecting';
    private static final String EMPTY_LIST_ASSERT_MESSAGE = 'Unexpected Result: Number of records returned does not match the expected outcome.';

    /**
     * @description It is used to test the initialisation of the domain class.
     */
    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<Event> eventInstantiate = new List<Event>();
        Events.newInstance(eventInstantiate);
        Events newEvent = new Events(eventInstantiate);
        Events.Constructor constructorObject = new Events.Constructor();
        constructorObject.construct(eventInstantiate);
        System.assertNotEquals(Events.newInstance(eventInstantiate), newEvent, UNEXPECTED_ERROR);
    }

    /**
     * @description To test First and Last qualified activity updated on Lead when an Event inserted
     * @JIRA# LEM-21484
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenEventInsertedThenUpdateFirstAndLastQualifiedOnLead() {
        Id leadId = Fake.generateId(Lead.class);
        Lead lead = (Lead) new Fake(Lead.class)
            .setField(Lead.Id, leadId)
            .setField(Lead.LastName, 'Test Name')
            .setField(Lead.Phone, '1234567899')
            .setField(Lead.Email, 'abc@email.com')
            .toSObject();
        Id eventId = Fake.generateId(Event.class);
        Event event = (Event) new Fake(Event.class)
            .setField(Event.Id, eventId)
            .setField(Event.Event_Status__c, EVENT_HELD)
            .setField(Event.DurationInMinutes, 10)
            .setField(Event.WhoId, leadId)
            .setField(Event.ActivityDateTime, AFTERTENDAYS)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUnitOfWork);
        ILeadsSelector mocksLeadsSelector = (ILeadsSelector) mocks.mock(ILeadsSelector.class);
        mocks.startStubbing();
        mocks.when(mocksLeadsSelector.sObjectType()).thenReturn(Schema.Lead.SObjectType);
        mocks.when(mocksLeadsSelector.selectById(new Set<Id>{ leadId }))
            .thenReturn(new List<Lead>{ lead });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mocksLeadsSelector);
        Test.startTest();
        Events.newInstance(new List<Event>{ event })
            .updateFirstAndLastQualifiedActivityOnLeadAndOpportunity();
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1)).commitWork();
    }

    /**
     * @description To test Last Meeting Ran on Lead when an Event inserted
     * @JIRA# LEM-21484
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenEventInsertedThenUpdateLastMeetingRanOnLead() {
        Id leadId = Fake.generateId(Lead.class);
        Lead lead = (Lead) new Fake(Lead.class)
            .setField(Lead.Id, leadId)
            .setField(Lead.LastName, 'Test Name')
            .setField(Lead.Phone, '1234567899')
            .setField(Lead.Email, 'abc@email.com')
            .toSObject();

        Id eventId = Fake.generateId(Event.class);
        Event event = (Event) new Fake(Event.class)
            .setField(Event.Id, eventId)
            .setField(Event.Event_Status__c, EVENT_HELD)
            .setField(Event.Subject, 'Meeting')
            .setField(Event.DurationInMinutes, 10)
            .setField(Event.WhoId, leadId)
            .setField(Event.ActivityDateTime, AFTERTENDAYS)
            .toSObject();

        List<Event> eventList = new List<Event>{
            new Event(
                Id = fflib_IDGenerator.generate(Schema.Event.SObjectType),
                Event_Status__c = EVENT_HELD,
                Subject = 'Meeting',
                DurationInMinutes = 10,
                WhoId = leadId,
                ActivityDateTime = AFTERTENDAYS
            ),
            new Event(
                Id = fflib_IDGenerator.generate(Schema.Event.SObjectType),
                Event_Status__c = EVENT_HELD,
                Subject = 'Meeting',
                DurationInMinutes = 10,
                WhoId = leadId,
                ActivityDateTime = AFTERTENDAYS
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUnitOfWork);
        ILeadsSelector mocksLeadsSelector = (ILeadsSelector) mocks.mock(ILeadsSelector.class);
        mocks.startStubbing();
        mocks.when(mocksLeadsSelector.sObjectType()).thenReturn(Schema.Lead.SObjectType);
        mocks.when(mocksLeadsSelector.selectById(new Set<Id>{ leadId }))
            .thenReturn(new List<Lead>{ lead });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mocksLeadsSelector);
        Test.startTest();
        Events.newInstance(eventList).updateLastMeetingRanOnLeadAndOpportunity();
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1)).commitWork();
    }
    /**
     * @description To test Last Meeting Ran on Lead when an Event inserted with different event status
     * @JIRA# LEM-21484
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenEventInsertedWithDifferentStatusThenDontUpdateLastMeetingRanOnLead() {
        Id leadId = Fake.generateId(Lead.class);
        Lead lead = (Lead) new Fake(Lead.class)
            .setField(Lead.Id, leadId)
            .setField(Lead.LastName, 'Test Name')
            .setField(Lead.Phone, '1234567899')
            .setField(Lead.Email, 'abc@email.com')
            .toSObject();
        Id eventId = Fake.generateId(Event.class);
        Event event = (Event) new Fake(Event.class)
            .setField(Event.Id, eventId)
            .setField(Event.Event_Status__c, 'Event Scheduled')
            .setField(Event.Subject, 'Meeting')
            .setField(Event.DurationInMinutes, 10)
            .setField(Event.WhoId, leadId)
            .setField(Event.ActivityDateTime, AFTERTENDAYS)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUnitOfWork);
        ILeadsSelector mocksLeadsSelector = (ILeadsSelector) mocks.mock(ILeadsSelector.class);
        mocks.startStubbing();
        mocks.when(mocksLeadsSelector.sObjectType()).thenReturn(Schema.Lead.SObjectType);
        mocks.when(mocksLeadsSelector.selectById(new Set<Id>{ leadId }))
            .thenReturn(new List<Lead>{ lead });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mocksLeadsSelector);
        Test.startTest();
        Events.newInstance(new List<Event>{ event }).updateLastMeetingRanOnLeadAndOpportunity();
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 0)).commitWork();
    }
    /**
     * @description To test Last Meeting Ran on Opportunity when an Event inserted
     * @JIRA# LEM-21484
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenEventInsertedThenUpdateLastMeetingRanOnOpportunity() {
        Id opportunityId = Fake.generateId(Opportunity.class);
        Opportunity opportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.StageName, PROSPECTING)
            .setField(Opportunity.CloseDate, Date.today())
            .toSObject();
        Id eventId = Fake.generateId(Event.class);
        Event event = (Event) new Fake(Event.class)
            .setField(Event.Id, eventId)
            .setField(Event.Event_Status__c, 'Event Held')
            .setField(Event.Subject, 'Meeting')
            .setField(Event.DurationInMinutes, 10)
            .setField(Event.WhatId, opportunityId)
            .setField(Event.ActivityDateTime, AFTERTENDAYS)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUnitOfWork);
        IOpportunitiesSelector mocksOpportunitiesSelector = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        mocks.startStubbing();
        mocks.when(mocksOpportunitiesSelector.sObjectType())
            .thenReturn(Schema.Opportunity.SObjectType);
        mocks.when(mocksOpportunitiesSelector.selectById(new Set<Id>{ opportunityId }))
            .thenReturn(new List<Opportunity>{ opportunity });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mocksOpportunitiesSelector);
        Test.startTest();
        Events.newInstance(new List<Event>{ event }).updateLastMeetingRanOnLeadAndOpportunity();
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1)).commitWork();
    }
    /**
     * @description To test Meeting Set on Opportunity when an Event inserted
     * @JIRA# LEM-21484
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenEventInsertedThenUpdateMeetingSetOnOpportunity() {
        Id opportunityId = Fake.generateId(Opportunity.class);
        Opportunity opportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.StageName, PROSPECTING)
            .setField(Opportunity.CloseDate, Date.today())
            .toSObject();

        Id eventId = Fake.generateId(Event.class);
        Event event = (Event) new Fake(Event.class)
            .setField(Event.Id, eventId)
            .setField(Event.Subject, 'Meeting')
            .setField(Event.StartDateTime, AFTERTENDAYS)
            .setField(Event.EndDateTime, AFTERTENDAYS)
            .setField(Event.DurationInMinutes, 10)
            .setField(Event.WhatId, opportunityId)
            .setField(Event.ActivityDateTime, AFTERTENDAYS)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        Application.UNITOFWORK.setMock(mockUnitOfWork);
        IOpportunitiesSelector mocksOpportunitiesSelector = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );

        mocks.startStubbing();
        mocks.when(mocksOpportunitiesSelector.sObjectType())
            .thenReturn(Schema.Opportunity.SObjectType);
        mocks.when(mocksOpportunitiesSelector.selectById(new Set<Id>{ opportunityId }))
            .thenReturn(new List<Opportunity>{ opportunity });

        mocks.stopStubbing();
        Application.SELECTOR.setMock(mocksOpportunitiesSelector);

        Test.startTest();
        Events.newInstance(new List<Event>{ event }).updateMeetingSetOnLeadAndOpportunity();
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1)).commitWork();
    }

    /**
     * @description To test Meeting Set on Opportunity when an Event Start Date Is updated
     * @JIRA# LEM-21484
     *
     * Today
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenEventStartDateUpdatedThenUpdateMeetingSetOnOpportunity() {
        Id opportunityId = Fake.generateId(Opportunity.class);
        Opportunity opportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.Meeting_Set__c, AFTERTENDAYS)
            .setField(Opportunity.StageName, PROSPECTING)
            .setField(Opportunity.CloseDate, Date.today())
            .toSObject();

        Id eventId = Fake.generateId(Event.class);
        Event event = (Event) new Fake(Event.class)
            .setField(Event.Id, eventId)
            .setField(Event.Subject, EVENT_SUBJECT)
            .setField(Event.Event_Status__c, EVENT_SCHEDULED)
            .setField(Event.StartDateTime, AFTERFIVEDAYS) 
            .setField(Event.EndDateTime, AFTERFIVEDAYS)
            .setField(Event.DurationInMinutes, 10)
            .setField(Event.WhatId, opportunityId)
            .setField(Event.ActivityDateTime, AFTERFIVEDAYS)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        Application.UNITOFWORK.setMock(mockUnitOfWork);
        IOpportunitiesSelector mocksOpportunitiesSelector = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );

        mocks.startStubbing();
        mocks.when(mocksOpportunitiesSelector.sObjectType())
            .thenReturn(Schema.Opportunity.SObjectType);
        mocks.when(mocksOpportunitiesSelector.selectById(new Set<Id>{ opportunityId }))
            .thenReturn(new List<Opportunity>{ opportunity });

        mocks.stopStubbing();
        Application.SELECTOR.setMock(mocksOpportunitiesSelector);

        Test.startTest();
        Events.newInstance(new List<Event>{ event })
            .updateMeetingSetOnLeadAndOpportunityOnEventStartDateUpdate();
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1)).commitWork();
    }

    /**
     * @description To test Meeting Set on Lead when an Event Start Date is Updated
     * @JIRA# LEM-21484
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenEventStartDateUpdatedWithEventHeldThenDontUpdateMeetingSetOnOpportunity() {
        Id opportunityId = Fake.generateId(Opportunity.class);
        Opportunity opportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.Meeting_Set__c, AFTERFIVEDAYS)
            .setField(Opportunity.StageName, PROSPECTING)
            .setField(Opportunity.CloseDate, CLOSE_DATE)
            .toSObject();

        Id eventId = Fake.generateId(Event.class);
        Event event = (Event) new Fake(Event.class)
            .setField(Event.Id, eventId)
            .setField(Event.Subject, EVENT_SUBJECT)
            .setField(Event.Event_Status__c, EVENT_HELD)
            .setField(Event.StartDateTime, AFTERTENDAYS)
            .setField(Event.EndDateTime, AFTERTENDAYS)
            .setField(Event.DurationInMinutes, 10)
            .setField(Event.ActivityDateTime, AFTERTENDAYS)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        Application.UNITOFWORK.setMock(mockUnitOfWork);
        IOpportunitiesSelector mocksOpportunitiesSelector = (IOpportunitiesSelector) mocks.mock(IOpportunitiesSelector.class);

        mocks.startStubbing();
        mocks.when(mocksOpportunitiesSelector.sObjectType()).thenReturn(Schema.Opportunity.SObjectType);
        mocks.when(mocksOpportunitiesSelector.selectById(new Set<Id>{ opportunityId }))
            .thenReturn(new List<Opportunity>{ opportunity });

        mocks.stopStubbing();
        Application.SELECTOR.setMock(mocksOpportunitiesSelector);

        Test.startTest();
        Events.newInstance(new List<Event>{ event })
            .updateMeetingSetOnLeadAndOpportunityOnEventStartDateUpdate();
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 0)).commitWork();
    }
    /**
     * @description To test Meeting Set on Lead when an Event inserted
     * @JIRA# LEM-21484
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenEventInsertedThenUpdateMeetingSetOnLead() {
        Id leadId = Fake.generateId(Lead.class);
        Lead lead = (Lead) new Fake(Lead.class)
            .setField(Lead.Id, leadId)
            .setField(Lead.LastName, 'Test Name')
            .setField(Lead.Phone, '1234567899')
            .setField(Lead.Email, 'abc@email.com')
            .toSObject();

        Id eventId = Fake.generateId(Event.class);
        Event event = (Event) new Fake(Event.class)
            .setField(Event.Id, eventId)
            //  .setField(Event.Event_Status__c, 'Event Held')
            .setField(Event.Subject, 'Meeting')
            .setField(Event.StartDateTime, AFTERTENDAYS)
            .setField(Event.EndDateTime, AFTERTENDAYS)
            .setField(Event.DurationInMinutes, 10)
            .setField(Event.WhoId, leadId)
            .setField(Event.ActivityDateTime, AFTERTENDAYS)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        Application.UNITOFWORK.setMock(mockUnitOfWork);
        ILeadsSelector mocksLeadsSelector = (ILeadsSelector) mocks.mock(ILeadsSelector.class);

        mocks.startStubbing();
        mocks.when(mocksLeadsSelector.sObjectType()).thenReturn(Schema.Lead.SObjectType);
        mocks.when(mocksLeadsSelector.selectById(new Set<Id>{ leadId }))
            .thenReturn(new List<Lead>{ lead });

        mocks.stopStubbing();
        Application.SELECTOR.setMock(mocksLeadsSelector);

        Test.startTest();
        Events.newInstance(new List<Event>{ event }).updateMeetingSetOnLeadAndOpportunity();
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1)).commitWork();
    }

    /**
     * @description To test First and Last qualified activity updated on Opportunity when an Event inserted
     */
    @isTest
    private static void testWhenEventInsertedThenUpdateFirstAndLastQualifiedOnOpportunity() {
        Id opportunityId = Fake.generateId(Opportunity.class);
        Opportunity opportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.StageName, PROSPECTING)
            .setField(Opportunity.CloseDate, Date.today())
            .toSObject();

        Id eventId = Fake.generateId(Event.class);
        Event event = (Event) new Fake(Event.class)
            .setField(Event.Id, eventId)
            .setField(Event.Event_Status__c, EVENT_HELD)
            .setField(Event.DurationInMinutes, 10)
            .setField(Event.WhatId, opportunityId)
            .setField(Event.ActivityDateTime, AFTERTENDAYS)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunitiesSelector mocksOpportunitiesSelector = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );

        mocks.startStubbing();
        mocks.when(mocksOpportunitiesSelector.sObjectType())
            .thenReturn(Schema.Opportunity.SObjectType);
        mocks.when(mocksOpportunitiesSelector.selectById(new Set<Id>{ opportunityId }))
            .thenReturn(new List<Opportunity>{ opportunity });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mocksOpportunitiesSelector);

        Test.startTest();
        Events.newInstance(new List<Event>{ event })
            .updateFirstAndLastQualifiedActivityOnLeadAndOpportunity();
        System.assertEquals(0, fflib_SObjects.Errors?.getAll().size(), 'No error shown');
        Test.stopTest();
    }

    /**
     * @description It is used to validate positive scenario for method to update SDR Required on Opportunity.
     */
    @isTest
    private static void testWhenEventMeetingMissedThenUpdateSDRTouchOnOpportunityPass() {
        Id opportunityId = Fake.generateId(Opportunity.class);
        Id opportunityTeamMemberId = Fake.generateId(Opportunity.class);

        Opportunity opportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.StageName, PROSPECTING)
            .setField(Opportunity.CloseDate, Date.today())
            .setField(Opportunity.OwnerID, UserInfo.getUserID())
            .setField(Opportunity.SDR_Touch_Required__c, null)
            //.setField(Opportunity.Name,'Test')
            .toSObject();
        OpportunityTeamMember opportunityTeamMember = (OpportunityTeamMember) new Fake(
                OpportunityTeamMember.class
            )
            .setField(opportunityTeamMember.Id, opportunityTeamMemberId)
            .setField(opportunityTeamMember.OpportunityId, opportunityId)
            .setField(opportunityTeamMember.TeamMemberRole, SALES_DEVELOPMENT_REP_ROLE)
            .setField(opportunityTeamMember.UserId, UserInfo.getUserID())
            .toSObject();

        Id eventId = Fake.generateId(Event.class);
        Event event = (Event) new Fake(Event.class)
            .setField(Event.Id, eventId)
            .setField(Event.DurationInMinutes, 10)
            .setField(Event.WhatId, opportunityId)
            .setField(Event.ActivityDateTime, AFTERTENDAYS)
            .setField(Event.Event_Status__c, EVENT_MISSED)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunityTeamMembersSelector mocksOpportunityTeamMemberSelector = (IOpportunityTeamMembersSelector) mocks.mock(
            IOpportunityTeamMembersSelector.class
        );

        mocks.startStubbing();
        mocks.when(mocksOpportunityTeamMemberSelector.sObjectType())
            .thenReturn(Schema.OpportunityTeamMember.SObjectType);
        mocks.when(
                mocksOpportunityTeamMemberSelector.selectByOpportunityIds(
                    new Set<Id>{ opportunityId }
                )
            )
            .thenReturn(new List<OpportunityTeamMember>{ opportunityTeamMember });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mocksOpportunityTeamMemberSelector);

        Test.startTest();
        Events.newInstance(new List<Event>{ event }).updateSDRTouchOnOpportunity();

        //System.assertEquals('Yes' ,opportunity.SDR_Touch_Required__c, SDR_NOT_MATCHING);
        System.assertEquals(0, fflib_SObjects.Errors?.getAll().size(), EMPTY_LIST_ASSERT_MESSAGE);

        Test.stopTest();
    }

    /**
     * @description It is used to validate positive scenario for method to update SDR Assisted on Opportunity.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenEventMeetingHeldThenUpdateSDRAssistedOnOpportunityPass() {
        Id opportunityId = Fake.generateId(Opportunity.class);
        Id opportunityTeamMemberId = Fake.generateId(opportunityTeamMember.class);
        Id userId = Fake.generateId(User.class);

        OpportunityTeamMember opportunityTeamMember = (OpportunityTeamMember) new Fake(
                OpportunityTeamMember.class
            )
            .setField(opportunityTeamMember.Id, opportunityTeamMemberId)
            .setField(opportunityTeamMember.OpportunityId, opportunityId)
            .setField(opportunityTeamMember.TeamMemberRole, SALES_DEVELOPMENT_REP_ROLE)
            .setField(opportunityTeamMember.UserId, userId)
            .toSObject();

        Id eventId = Fake.generateId(Event.class);
        Event event = (Event) new Fake(Event.class)
            .setField(Event.Id, eventId)
            .setField(Event.DurationInMinutes, 10)
            .setField(Event.WhatId, opportunityId)
            .setField(Event.ActivityDateTime, AFTERTENDAYS)
            .setField(Event.Event_Status__c, EVENT_HELD)
            .setField(Event.createdById, userId)
            .setField(Event.lastModifiedDate, Date.Today())
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunityTeamMembersSelector mocksOpportunityTeamMemberSelector = (IOpportunityTeamMembersSelector) mocks.mock(
            IOpportunityTeamMembersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(mocksOpportunityTeamMemberSelector.sObjectType())
            .thenReturn(Schema.OpportunityTeamMember.SObjectType);
        mocks.when(
                mocksOpportunityTeamMemberSelector.selectByOpportunityIds(
                    new Set<Id>{ opportunityId }
                )
            )
            .thenReturn(new List<OpportunityTeamMember>{ opportunityTeamMember });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUnitOfWork);
        Application.SELECTOR.setMock(mocksOpportunityTeamMemberSelector);

        Test.startTest();
        Events.newInstance(new List<Event>{ event }).updateSDRAssistedFieldOnOpportunity();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Opportunity.SDR_Assisted_Task_Id__c => event.Id,
                        Opportunity.SDR_Assisted__c => date.newinstance(
                            event.lastModifiedDate.year(),
                            event.lastModifiedDate.month(),
                            event.lastModifiedDate.day()
                        )
                    }
                )
            );

        Test.stopTest();
    }
}