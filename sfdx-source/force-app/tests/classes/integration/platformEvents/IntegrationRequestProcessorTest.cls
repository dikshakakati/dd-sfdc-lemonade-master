/**
 * @author BizApps
 * @date 11/26/2024
 * @description Test class for IntegrationRequestProcessor Platform event trigger
 */
@isTest(SeeAllData=false)
public class IntegrationRequestProcessorTest {
    private static final String EVENT_TOPIC_INITIATE_POS_CHILD_WORK_ORDERS_CREATION = 'INITIATE_POS_CHILD_WORK_ORDERS_CREATION';
    private static final String EVENT_BUS_SUBSCRIBER_NAME = 'NotifierEvents';
    private static final String EVENT_BUS_SUBSCRIBER_TYPE = 'ApexTrigger';
    private static final String EVENT_BUS_SUBSCRIBER_TYPE_DOES_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: the event bus subscriber Type does not match with ApexTrigger';
    private static final string INTEGRATION_TYPE_POS = 'POS Requests';
    private static final String NOTIFIER_EVENT = 'Integration_Request_Processor__e';
    private static final string ONBOARDING_ID = '222-8888-999-4444';
    private static final String STATUS_PENDING = 'Pending';
    private static final String STORE_ID = '24680';
    private static final string SFDC_ORG_LEMONADE = 'Lemonade';


     /**
      * @description To test IntegrationRequestProcessor events subscription by the trigger handler.
      */
     @isTest
     private static void testWhenWorkOrderProcessorPublishedThenNotifierEventsTriggerListens() {
     	Integration_Request__c irRequest = ServiceIntegrationDataBuilder.createIntegrationRequestInstance(
            STORE_ID
        );
        irRequest.Onboarding_Id__c = ONBOARDING_ID;
        irRequest.SFDC_Org__c = SFDC_ORG_LEMONADE;
        irRequest.Integration_Type__c = INTEGRATION_TYPE_POS;
        irRequest.Sfdc_Status__c = STATUS_PENDING;
        insert irRequest;

         Test.startTest();
         NotifierEventsService.publishBulkEvents(
             new Map<String, List<String>>{
                 EVENT_TOPIC_INITIATE_POS_CHILD_WORK_ORDERS_CREATION => new List<String>{
                     JSON.serialize(new List<String>{ irRequest.ID })
                 }
             }
         );
         Test.stopTest();
         List<EventBusSubscriber> eventBusSubscriberResult = [
             SELECT Name, Type
             FROM EventBusSubscriber
             WHERE Topic = :NOTIFIER_EVENT
         ];
           System.assertEquals(
             EVENT_BUS_SUBSCRIBER_TYPE,
             eventBusSubscriberResult[0].Type,
             EVENT_BUS_SUBSCRIBER_TYPE_DOES_NOT_MATCH_ASSERT_MESSAGE
         );
    }
}