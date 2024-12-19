/**
 * @author Deloitte
 * @date 17/05/2022
 * @description Integration test class for WorkOrder Processor trigger.
 */

 @isTest(SeeAllData=false)
 private class WorkOrderProcessorIntegrationTest {
     private static final string ACCOUNT_PARTNERSHIP_STATUS = 'Prospective Partner';
     private static final string ACCOUNT_BILLING_CITY = 'Missoula';
     private static final string ACCOUNT_BILLING_COUNTRY = 'United States';
     private static final string ACCOUNT_BILLING_POSTAL_CODE = '1234';
     private static final string ACCOUNT_BILLING_STATE = 'California';
     private static final string ACCOUNT_BILLING_STREET = '221B Baker Street';
     private static final string ACCOUNT_RECORD_TYPE_BUSINESS = 'Business';
     private static final string ACCOUNT_RECORD_TYPE_STORE = 'Store';
     private static final String ACCOUNT_SEGMENT_ENTERPRISE = 'Enterprise';
     private static final string BUSINESS_ACCOUNT_NAME = 'Test Business Account';
     private static final String EVENT_BUS_SUBSCRIBER_NAME = 'WorkOrderProcessor';
     private static final String EVENT_BUS_SUBSCRIBER_TYPE = 'ApexTrigger';
     private static final String EVENT_BUS_SUBSCRIBER_NAME_DOES_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: the event bus subscriber Name does not match with NotifierEvents';
     private static final String EVENT_BUS_SUBSCRIBER_TYPE_DOES_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: the event bus subscriber Type does not match with ApexTrigger';
     private static final String WORK_ORDER_READY_FOR_PROVISIONING_STATUS_UPDATE = 'WORK_ORDER_READY_FOR_PROVISIONING_STATUS_UPDATE';
     private static final String NOTIFIER_EVENT = 'Work_Order_Processor__e';
     private static final String OPPORTUNITY_NAME = 'McDonald Test';
     private static final String OPPORTUNITY_STAGE = 'Prospecting';
     private static final string STORE_ACCOUNT_NAME = 'Test Store Account';
     private static final String WORK_ORDER_AC = 'Yes';
     private static final String WORK_ORDER_MENU_TO_BE_COMPLETED_BY = 'Merchant';
     private static final String WORK_ORDER_STATUS = 'Planning';
     private static final String WORK_ORDER_TYPE = 'COO';


     /**
      * @description To test WorkOrderProcessor events subscription by the trigger handler.
      */
     @isTest
     private static void testWhenWorkOrderProcessorPublishedThenNotifierEventsTriggerListens() {
         Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
             .get(ACCOUNT_RECORD_TYPE_BUSINESS)
             .getRecordTypeId();
         Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
             .get(ACCOUNT_RECORD_TYPE_STORE)
             .getRecordTypeId();
         Account parentAccount = new Account(
             Name = BUSINESS_ACCOUNT_NAME,
             RecordTypeId = businessRecordTypeId,
             Segment__c = ACCOUNT_SEGMENT_ENTERPRISE
         );
         insert parentAccount;
         Account storeAccount = new Account(
             BillingStreet = ACCOUNT_BILLING_STREET,
             Name = STORE_ACCOUNT_NAME,
             ParentId = parentAccount.Id,
             Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
             RecordTypeId = storeRecordTypeId,
             BillingCity = ACCOUNT_BILLING_CITY,
             BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
             BillingCountry = ACCOUNT_BILLING_COUNTRY,
             BillingState = ACCOUNT_BILLING_STATE,
             Segment__c = ACCOUNT_SEGMENT_ENTERPRISE

         );
         insert storeAccount;
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
             StageName = OPPORTUNITY_STAGE
         );
         insert parentOpportunity;
         WorkOrder parentWorkOrder = new WorkOrder(
             AccountId = parentAccount.Id,
             Activated_Centrally_AC__c = WORK_ORDER_AC,
             Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
             Opportunity__c = parentOpportunity.Id,
             Proposed_Date_of_Activation__c = System.today().addDays(10),
             Status = WORK_ORDER_STATUS,
             Type__c = WORK_ORDER_TYPE
         );
         insert parentWorkOrder;
         WorkOrder newWorkOrder = new WorkOrder(
             Activated_Centrally_AC__c = WORK_ORDER_AC,
             AccountId = storeAccount.Id,
             Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
             Proposed_Date_of_Activation__c = System.today().addDays(10),
             ParentWorkOrderId = parentWorkOrder.Id,
             Status = WORK_ORDER_STATUS,
             Type__c = WORK_ORDER_TYPE
         );
         insert newWorkOrder;
         Test.startTest();
         NotifierEventsService.publishBulkEvents(
             new Map<String, List<String>>{
                 WORK_ORDER_READY_FOR_PROVISIONING_STATUS_UPDATE => new List<String>{
                     JSON.serialize(new List<Id>{ parentWorkOrder.Id })
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