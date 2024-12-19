/**
 * @author Deloitte
 * @date 10/03/2022
 * @description Test class for NotifierEventsPayloadGenerationSrvcImpl class.
 */
@isTest(SeeAllData=false)
public class NotifierEventsPayloadGenSrvcImplTest {
    private static final String ASSERT_MESSAGE_MISMATCHED_PAYLOAD = 'Unexpected result: payload is mismatching';
    private static final Integer CHUNK_SIZE = 3;

    /**
     * @description To test payload generation using the passed sobjectIds and chunk size.
     */
    @isTest
    private static void testWhenOrderItemIdsReceivedThenPayloadsGenerated() {
        Id caviarOrderItemId = fflib_IDGenerator.generate(OrderItem.SObjectType);
        Id dashpassOrderItemId = fflib_IDGenerator.generate(OrderItem.SObjectType);
        Id deliveryOrderItemId = fflib_IDGenerator.generate(OrderItem.SObjectType);
        Id marketplaceOrderItemId = fflib_IDGenerator.generate(OrderItem.SObjectType);
        Id pickupOrderItemId = fflib_IDGenerator.generate(OrderItem.SObjectType);
        List<Id> orderItemIdsChunk1 = new List<Id>{
            caviarOrderItemId,
            dashpassOrderItemId,
            deliveryOrderItemId
        };
        List<Id> orderItemIdsChunk2 = new List<Id>{ marketplaceOrderItemId, pickupOrderItemId };
        List<String> payloads = new List<String>{
            JSON.serialize(orderItemIdsChunk1),
            JSON.serialize(orderItemIdsChunk2)
        };
        Test.startTest();
        List<String> generatedPayloads = NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
            new Set<Id>{
                caviarOrderItemId,
                dashpassOrderItemId,
                deliveryOrderItemId,
                marketplaceOrderItemId,
                pickupOrderItemId
            },
            CHUNK_SIZE
        );
        Test.stopTest();
        System.assertEquals(payloads, generatedPayloads, ASSERT_MESSAGE_MISMATCHED_PAYLOAD);
    }

    /*
     * @description To test payload generation using the passed objects and chunk size.
     */
    @isTest
    static void testWhenObjectsReceivedThenPayloadsGenerated() {
        Object obj1 = 'rando obj';
        Object obj2 = 4567;
        Object obj3 = 0.9876;
        Object obj4 = new Account();
        Object obj5 = new Map<String, Object>();

        List<String> payloads = new List<String>{
            JSON.serialize(new Set<Object>{ obj1, obj2, obj3 }),
            JSON.serialize(new Set<Object>{ obj4, obj5 })
        };
        Test.startTest();
        List<String> generatedPayloads = NotifierEventsPayloadGenerationService.generateChunkedPayloadsByObjects(
            new Set<Object>{ obj1, obj2, obj3, obj4, obj5 },
            CHUNK_SIZE
        );
        Test.stopTest();
        System.assertEquals(payloads, generatedPayloads, ASSERT_MESSAGE_MISMATCHED_PAYLOAD);
    }

    /*
     * @description To test payload generation using the passed sObjects and chunk size.
     */
    @isTest
    private static void testWhenSObjectsAndChunkSizeReceivedThenPayloadsGenerated() {
        Set<SObject> workSteps =  new Set<SObject>{
                    new WorkStep(Id = fflib_IDGenerator.generate(WorkStep.SObjectType)),
                    new WorkStep(Id = fflib_IDGenerator.generate(WorkStep.SObjectType))
                };
        List<String> payloads = new List<String>{
            JSON.serialize(
                workSteps
            )
        };
        Test.startTest();
        List<String> generatedPayloads = NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySObjects(
           	workSteps,
            CHUNK_SIZE
        );
        Test.stopTest();
        System.assertEquals(payloads, generatedPayloads, ASSERT_MESSAGE_MISMATCHED_PAYLOAD);
    }
}