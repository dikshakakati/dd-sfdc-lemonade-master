/**
 * @author Deloitte
 * @date 05/09/2024
 * @description Integration test class for EmailOutboundIntegrationsEvents trigger.
 */
@isTest(seeAllData=false)
public class EmailOutboundEventsIntegrationTest {
    private static final string ACCOUNT_RECORD_TYPE_BUSINESS = 'Business';
    private static final string ACCOUNT_SEGMENT = 'SMB';
    private static final string BUSINESS_ACCOUNT_NAME = 'Test Business Account';
    private static final String EVENT_BUS_SUBSCRIBER_NAME = 'EmailOutboundIntegrationsEvents';
    private static final String EVENT_BUS_SUBSCRIBER_TYPE = 'ApexTrigger';
    private static final String EVENT_BUS_SUBSCRIBER_NAME_DOES_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: the event bus subscriber Name does not match with EmailOutboundIntegrationsEvents';
    private static final String EVENT_BUS_SUBSCRIBER_TYPE_DOES_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: the event bus subscriber Type does not match with ApexTrigger';
    private static final String EVENT_TOPIC_EMAIL_OUTBOUND_INTEGRATION = 'EMAIL_OUTBOUND_INTEGRATION';
    private static final String NOTIFIER_EVENT = 'Email_Outbound_Integration__e';
    private static final String OPPORTUNITY_NAME = 'McDonald Test';
    private static final String OPPORTUNITY_STAGE = 'Prospecting';

    /**
     * @description To test Email outbound events subscription by the trigger handler.
     */
    @isTest
    private static void testWhenEmailOutboundEventPublishedThenEmailOutboundEventsTriggerListens() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_RECORD_TYPE_BUSINESS)
            .getRecordTypeId();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT
        );
        insert parentAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            CloseDate = System.today().addDays(5),
            Pricebook2Id = Test.getStandardPricebookId(),
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        Test.startTest();
        EmailOutboundIntegrationsEventsService.publishEvents(
            new Map<String, String>{
                EVENT_TOPIC_EMAIL_OUTBOUND_INTEGRATION => JSON.serialize(
                    new Set<Id>{ parentOpportunity.Id }
                )
            }
        );
        Test.stopTest();
        List<EventBusSubscriber> eventBusSubscriberResult = [
            SELECT Name, Type
            FROM EventBusSubscriber
            WHERE Topic = :NOTIFIER_EVENT
        ];
        System.assertEquals(
            EVENT_BUS_SUBSCRIBER_NAME,
            eventBusSubscriberResult[0].Name,
            EVENT_BUS_SUBSCRIBER_NAME_DOES_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            EVENT_BUS_SUBSCRIBER_TYPE,
            eventBusSubscriberResult[0].Type,
            EVENT_BUS_SUBSCRIBER_TYPE_DOES_NOT_MATCH_ASSERT_MESSAGE
        );
    }
}