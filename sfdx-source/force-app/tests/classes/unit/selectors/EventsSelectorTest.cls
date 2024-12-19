/**
 * @author Deloitte
 * @date 06/12/2024
 * @description Test class for EventsSelector class.
 */
@isTest(SeeAllData=false)
private class EventsSelectorTest {
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: There is a mismatch in fields list.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: The object type must be Event.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_NUMBER_OF_EVENTS = 'Unexpected result: The number of events returned do not match the expected number of events.';
    private static final String EVENT_STATUS_HELD = 'Event Held';
    private static final String EVENT_STATUS_MISSED = 'Event Missed';
    private static final Date AFTERTENDAYS = System.today().addDays(10);
    private static final String ASSERT_MESSAGE_MISMATCH_IN_WHATID = 'Unexpected result: The WhatId of events returned do not match the expected related Sobject Id.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_EVENT_COUNT = 'Unexpected result: The count of events returned do not match the expected count.';
    private static final String ACCOUNT_NAME = 'Test Account';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String OPPORTUNITY_NAME = 'Test Opportunity';
    private static final String OPPORTUNITY_STAGENAME = 'Needs Analysis';
    private static final String LEAD_LAST_NAME = 'Test Lead';
    private static final String LEAD_EMAIL = 'abc@Email.com';
    private static final String LEAD_COMPANY = 'Test Company';
    private static final String ASSERT_MESSAGE_IN_NUMBER_OF_EVENTS = 'Expected result: Events are returning according to the WhatIds Or WhoIds';
    private static final String ASSERT_MESSAGE_MATCH_IN_WHATID = 'WhatId is matching with the Opportunity Id';
    private static final String ASSERT_MESSAGE_MATCH_IN_WHOID = 'WhoId is matching with the Lead Id';

    /**
     * @description To test contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        EventsSelector eventsSelectorInstance = new EventsSelector();
        Schema.SObjectType typeOfObject = eventsSelectorInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = eventsSelectorInstance.getSObjectFieldList();
        EventsSelector.newInstance();
        System.assertEquals(
            Schema.Event.SObjectType,
            typeOfObject,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Event.Id,
                Event.OwnerId,
                Event.Event_Status__c,
                Event.WhoId,
                Event.WhatId,
                Event.Subject,
                Event.StartDateTime
            },
            sObjectFields,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }

    /**
     * @description To test if the expected event records are returned.
     */
    @isTest
    private static void testWhenWhatIdsAndStatusPassedThenReturnEvents() {
        Account parentAccount = new Account(Name = ACCOUNT_NAME, Segment__c = SEGMENT_SMB);
        insert parentAccount;
        Opportunity opportunity = new Opportunity();
        opportunity.Name = OPPORTUNITY_NAME;
        opportunity.StageName = OPPORTUNITY_STAGENAME;
        opportunity.CloseDate = System.today().addDays(5);
        opportunity.AccountId = parentAccount.Id;
        opportunity.Estimated_Number_of_Stores__c = 1;
        insert opportunity;
        Event newEvent = new Event();
        newEvent.DurationInMinutes = 10;
        newEvent.WhatId = opportunity.Id;
        newEvent.ActivityDateTime = AFTERTENDAYS;
        newEvent.Event_Status__c = EVENT_STATUS_HELD;
        insert newEvent;
        Test.startTest();
        Aggregate[] results = EventsSelector.newInstance()
            .selectCountOfEventsByStatusAndRelatedToIds(
                new Set<Id>{ opportunity.Id },
                EVENT_STATUS_HELD
            );
        Test.stopTest();
        System.assertEquals(1, results.size(), ASSERT_MESSAGE_MISMATCH_IN_NUMBER_OF_EVENTS);
        System.assertEquals(
            opportunity.Id,
            (Id) results[0].get('WhatId'),
            ASSERT_MESSAGE_MISMATCH_IN_WHATID
        );
        System.assertEquals(
            1,
            (Integer) results[0].get('countIds'),
            ASSERT_MESSAGE_MISMATCH_IN_EVENT_COUNT
        );
    }
    /**
     * @description To test if the expected event records are returned.
     */
    @isTest
    private static void testWhenWhatIdsAndStatusPassedThenReturnEventsNegative() {
        Account parentAccount = new Account(Name = ACCOUNT_NAME, Segment__c = SEGMENT_SMB);
        insert parentAccount;
        Opportunity opportunity = new Opportunity();
        opportunity.Name = OPPORTUNITY_NAME;
        opportunity.StageName = OPPORTUNITY_STAGENAME;
        opportunity.CloseDate = System.today().addDays(5);
        opportunity.AccountId = parentAccount.Id;
        opportunity.Estimated_Number_of_Stores__c = 1;
        insert opportunity;
        Event newEvent = new Event();
        newEvent.DurationInMinutes = 10;
        newEvent.WhatId = opportunity.Id;
        newEvent.ActivityDateTime = AFTERTENDAYS;
        newEvent.Event_Status__c = EVENT_STATUS_MISSED;
        insert newEvent;
        Test.startTest();
        Aggregate[] results = EventsSelector.newInstance()
            .selectCountOfEventsByStatusAndRelatedToIds(
                new Set<Id>{ opportunity.Id },
                EVENT_STATUS_HELD
            );
        Test.stopTest();
        System.assertEquals(0, results.size(), ASSERT_MESSAGE_MISMATCH_IN_NUMBER_OF_EVENTS);
    }

    /**
     * @description It is used to test when any Opportunity associated to event, then return events.
     */
    @isTest
    private static void testWhenWhatIdsPassedThenReturnEvents() {
        Account parentAccount = new Account(Name = ACCOUNT_NAME, Segment__c = SEGMENT_SMB);
        insert parentAccount;
        Opportunity opportunity = new Opportunity(
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGENAME,
            CloseDate = System.today().addDays(5),
            AccountId = parentAccount.Id,
            Estimated_Number_of_Stores__c = 1
        );
        insert opportunity;
        Event newEvent = new Event(
            DurationInMinutes = 10,
            WhatId = opportunity.Id,
            ActivityDateTime = AFTERTENDAYS,
            Event_Status__c = EVENT_STATUS_HELD
        );
        insert newEvent;
        Test.startTest();
        List<Event> events = EventsSelector.newInstance()
            .selectByWhatIdAndWhoId(new Set<Id>{ opportunity.Id });
        Test.stopTest();
        System.assertEquals(1, events.size(), ASSERT_MESSAGE_IN_NUMBER_OF_EVENTS);
        System.assertEquals(opportunity.Id, (Id) events[0].WhatId, ASSERT_MESSAGE_MATCH_IN_WHATID);
    }

    /**
     * @description It is used to test when any Lead associated to event, then return events.
     */
    @isTest
    private static void testWhenWhoIdsPassedThenReturnEvents() {
        Lead lead = new Lead(lastName = LEAD_LAST_NAME, Email = LEAD_EMAIL, Company = LEAD_COMPANY);
        insert lead;
        Event newEvent = new Event(
            DurationInMinutes = 10,
            WhoId = lead.Id,
            ActivityDateTime = AFTERTENDAYS,
            Event_Status__c = EVENT_STATUS_HELD
        );
        insert newEvent;
        Test.startTest();
        List<Event> events = EventsSelector.newInstance()
            .selectByWhatIdAndWhoId(new Set<Id>{ lead.Id });
        Test.stopTest();
        System.assertEquals(1, events.size(), ASSERT_MESSAGE_IN_NUMBER_OF_EVENTS);
        System.assertEquals(lead.Id, (Id) events[0].WhoId, ASSERT_MESSAGE_MATCH_IN_WHOID);
    }

    /**
     * @description To test whether there is no related Opportunity or Lead associated with any event, then return no events.
     */
    @isTest
    private static void testWhenWhoIdsOrWhatIdsNotPassedThenReturnNoEvents() {
        Lead lead = new Lead(lastName = LEAD_LAST_NAME, Email = LEAD_EMAIL, Company = LEAD_COMPANY);
        insert lead;
        Event newEvent = new Event(
            DurationInMinutes = 10,
            ActivityDateTime = AFTERTENDAYS,
            Event_Status__c = EVENT_STATUS_HELD
        );
        insert newEvent;
        Test.startTest();
        List<Event> events = EventsSelector.newInstance()
            .selectByWhatIdAndWhoId(new Set<Id>{ lead.Id });
        Test.stopTest();
        System.assertNotEquals(1, events.size(), ASSERT_MESSAGE_MISMATCH_IN_NUMBER_OF_EVENTS);
    }
}