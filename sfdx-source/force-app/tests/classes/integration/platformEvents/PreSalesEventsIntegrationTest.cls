/**
 * @author Deloitte
 * @date 05/11/2024
 * @description Test class for PreSalesTransactionEvents Trigger.
 */
@isTest
public class PreSalesEventsIntegrationTest {
    private static final String UNIQUE_IDENTIFIER = '92108a53-e8d9-4a0c-9193-9152aeb86fe4';
    private static final String EVENT_BUS_SUBSCRIBER_NAME = 'PreSalesTransactionEvents';
    private static final String EVENT_BUS_SUBSCRIBER_TYPE = 'ApexTrigger';
    private static final String EVENT_BUS_SUBSCRIBER_NAME_DOES_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: the event bus subscriber Name does not match with PreSalesTransactionEvents';
    private static final String EVENT_BUS_SUBSCRIBER_TYPE_DOES_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: the event bus subscriber Type does not match with ApexTrigger';
    private static final String PRE_SALES_EVENT = 'PreSalesTransaction__e';
    private static final string STORE_ACCOUNT_NAME = 'Test Store Account';
    private static final String SSMO_EVENT_SERVICE = 'SSMO_EVENT_SERVICE';

    /**
     * @description To test Pre Sales events subscription by the trigger handler.
     */
    @isTest
    private static void testWhenPreSalesEventPublishedThenPreSalesEventsTriggerListens() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Inbound_Ingestion_Log__c inboundIngestionLog = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            UUID__c = UNIQUE_IDENTIFIER
        );
        Test.startTest();
        InstantIngestorEventsService.publishEvents(
            new Map<String, String>{
                SSMO_EVENT_SERVICE => JSON.serialize(new Set<Id>{ inboundIngestionLog.Id })
            },
            PreSalesTransaction__e.SObjectType
        );
        Test.stopTest();
        List<EventBusSubscriber> eventBusSubscriberResult = [
            SELECT Name, Type
            FROM EventBusSubscriber
            WHERE Topic = :PRE_SALES_EVENT
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