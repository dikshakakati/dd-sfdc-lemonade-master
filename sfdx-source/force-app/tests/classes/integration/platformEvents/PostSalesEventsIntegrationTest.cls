/**
 * @author Deloitte
 * @date 05/11/2024
 * @description Test class for PostSalesTransactionEvents Trigger.
 */
@isTest
public class PostSalesEventsIntegrationTest {
    private static final String UNIQUE_IDENTIFIER = '92108a53-e8d9-4a0c-9193-9152aeb86fe4';
    private static final String EVENT_BUS_SUBSCRIBER_NAME = 'PostSalesTransactionEvents';
    private static final String EVENT_BUS_SUBSCRIBER_TYPE = 'ApexTrigger';
    private static final String EVENT_BUS_SUBSCRIBER_NAME_DOES_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: the event bus subscriber Name does not match with PostSalesTransactionEvents';
    private static final String EVENT_BUS_SUBSCRIBER_TYPE_DOES_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: the event bus subscriber Type does not match with ApexTrigger';
    private static final String POST_SALES_EVENT = 'PostSalesTransaction__e';
    private static final string STORE_ACCOUNT_NAME = 'Test Store Account';
    private static final String SSOB_EVENT_SERVICE = 'SSOB_EVENT_SERVICE';

    /**
     * @description To test PostSales events subscription by the trigger handler.
     */
    @isTest
    private static void testWhenPostSalesEventPublishedThenPostSalesEventsTriggerListens() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Inbound_Ingestion_Log__c inboundIngestionLog = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            UUID__c = UNIQUE_IDENTIFIER
        );
        Test.startTest();
        InstantIngestorEventsService.publishEvents(
            new Map<String, String>{
                SSOB_EVENT_SERVICE => JSON.serialize(new Set<Id>{ inboundIngestionLog.Id })
            },
            PostSalesTransaction__e.SObjectType
        );
        Test.stopTest();
        List<EventBusSubscriber> eventBusSubscriberResult = [
            SELECT Name, Type
            FROM EventBusSubscriber
            WHERE Topic = :POST_SALES_EVENT
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