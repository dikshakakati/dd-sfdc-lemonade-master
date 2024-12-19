/**
 * @description This is test class for EventBusTriggerContextImpl
 * @author Deloitte
 * @date 22/03/2022
 */
@isTest(seeAllData=false)
public class EventBusTriggerContextImplTest {
    /**
     * @description To test EventBusTriggerContext
     */
    @IsTest
    private static void testWhenEventInsertedThenSetCheckpoint() {
        RollUpEvent__e evt = new RollUpEvent__e();
        evt.RecordId__c = Fake.generateId(Account.class);
        evt.Type__c = 'Store Count';

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountRollupService accountRollUpServiceMock = (IAccountRollupService) mocks.mock(
            IAccountRollupService.class
        );
        Application.SERVICE.setMock(IAccountRollupService.class, accountRollUpServiceMock);

        Test.startTest();
        Database.SaveResult eventResult = EventBus.publish(evt);
        Test.stopTest();

        System.assertEquals(true, eventResult.isSuccess(), 'Platform event not published');
        System.assertEquals(0, new EventBusTriggerContextImpl().retries, 'No. of retries is not 0');
        System.assertEquals(
            null,
            new EventBusTriggerContextImpl().lastError,
            'Last error is not null'
        );
        System.assertEquals(
            null,
            EventBusTriggerContext.getResumeCheckpoint(),
            'Get resume checkpoint is not null'
        );
        System.assertNotEquals(
            null,
            EventBusTriggerContext.currentContext(),
            'Current context is null'
        );
    }
}