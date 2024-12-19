/**
 * @author Deloitte
 * @date 17/05/2022
 * @description Test class for NotifierEventsServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class NotifierEventsServiceImplTest {
    private static final String EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION = 'WORK_ORDER_STORES_CALCULATION';
    private static final String ACCOUNT_WO_SYNC_UPDATES = 'Account_WO_Sync_Updates';

    /**
     * @description To test creation of Notifier events on publishEvents method call
     * with UOW instance and payload.
     */
    @isTest
    private static void testWhenPublishEventsCalledWithUOWAndPayloadThenNotifierEventPublished() {
        Set<Id> mockParentWorkOrderIds = new Set<Id>{
            fflib_IDGenerator.generate(WorkOrder.SObjectType),
            fflib_IDGenerator.generate(WorkOrder.SObjectType)
        };
        Map<String, String> mockPayload = new Map<String, String>{
            'WORK_ORDER_STORES_CALCULATION' => JSON.serialize(mockParentWorkOrderIds)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        NotifierEventsService.publishEvents(mockPayload, mockUOW);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description To test creation of Notifier events on publishEvents method call with payload.
     */
    @isTest
    private static void testWhenPublishEventsCalledWithPayloadThenNotifierEventPublished() {
        Set<Id> mockParentWorkOrderIds = new Set<Id>{
            fflib_IDGenerator.generate(WorkOrder.SObjectType),
            fflib_IDGenerator.generate(WorkOrder.SObjectType)
        };
        Map<String, String> mockPayload = new Map<String, String>{
            'WORK_ORDER_STORES_CALCULATION' => JSON.serialize(mockParentWorkOrderIds)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        NotifierEventsService.publishEvents(mockPayload);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description To test Notifier event is not published on publishEvents method call with
     * UOW instance and payload as null.
     */
    @isTest
    private static void testWhenPublishEventsCalledWithUOWAndNullPayloadThenNotifierEventNotPublished() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        NotifierEventsService.publishEvents(null, mockUOW);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test Notifier event is not published on publishEvents method call with
     * payload as null.
     */
    @isTest
    private static void testWhenPublishEventsCalledWithNullPayloadThenNotifierEventNotPublished() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        NotifierEventsService.publishEvents(null);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test creation of Notifier events on publishBulkEvents method call
     * with payloads.
     */
    @isTest
    private static void testWhenPublishBulkEventsCalledWithPayloadThenNotifierEventPublished() {
        List<String> mockMergedPayloads = new List<String>{
            fflib_IDGenerator.generate(WorkOrder.SObjectType),
            fflib_IDGenerator.generate(WorkOrder.SObjectType)
        };
        Map<String, List<String>> mockPayload = new Map<String, List<String>>{
            'WORK_ORDER_STORES_CALCULATION' => mockMergedPayloads
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        NotifierEventsService.publishBulkEvents(mockPayload);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description To test Notifier event is not published on publishBulkEvents method call with
     * payload as null.
     */
    @isTest
    private static void testWhenPublishBulkEventsCalledWithNullPayloadThenNotifierEventNotPublished() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        NotifierEventsService.publishBulkEvents(null);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }
    /**
     * @description To test Generic log
     * call with list of payloads, and only 1 commit.
     */
    @isTest
    private static void testWhenGetGenericLogThenPublishGenericLog() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        Exception commitException = new System.DmlException();
        commitException.setMessage('Error occured');

        NotifierEventsServiceImpl.genericLogList.add(
            NotifierEventsServiceImpl.getGenericLog().logException(commitException)
        );
        NotifierEventsServiceImpl.publishGenericLog();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test creation of Notifier events on publishBulkEvents method call with
     * payloads.
     */
    @isTest
    private static void testWhenPublishedWorkOrderBulkEventsThenNotifierEventPublishedWithPartitionKey() {
        List<String> mockMergedPayloads = new List<String>{
            fflib_IDGenerator.generate(WorkOrder.SObjectType)
        };
        Map<String, List<String>> mockPayload = new Map<String, List<String>>{
            EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION => mockMergedPayloads
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        NotifierEventsService.publishBulkEvents(mockPayload);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerPublishAfterSuccessTransaction(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Notifier__e.Partition_Key__c => ACCOUNT_WO_SYNC_UPDATES
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }
}