/**
 * @description Test Class for Events Trigger.
 * @date 05/03/2024
 * @author Deloitte
 */
@isTest
private class EventsIntegrationTest {
    private static final Date AFTERTENDAYS = System.today().addDays(10);
    private static final String EVENT_MISSED = 'Event Missed';

    /**
     * @description : It is used to valdiate insert on Event.
     */
    @isTest
    public static void testWhenDmlOccursThenTriggerFires() {
        Account parentAccount = new Account(Name = 'Test Account', Segment__c = 'SMB');
        insert parentAccount;

        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'Test1';
        opportunity.StageName = 'Needs Analysis';
        opportunity.CloseDate = System.today().addDays(5);
        opportunity.AccountId = parentAccount.Id;
        opportunity.Estimated_Number_of_Stores__c = 1;
        insert opportunity;

        Event newEvent = new Event();
        newEvent.DurationInMinutes = 10;
        newEvent.WhatId = opportunity.Id;
        newEvent.ActivityDateTime = AFTERTENDAYS;
        newEvent.Event_Status__c = EVENT_MISSED;
        insert newEvent;

        List<Event> insertedEvents = [
            SELECT Id, Event_Status__c
            FROM Event
            WHERE WhatId = :opportunity.Id
        ];

        System.assertEquals(1, insertedEvents.size(), 'Number of Opportunities do not match');
    }
}