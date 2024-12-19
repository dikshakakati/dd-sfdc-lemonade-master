/**
 * @author Deloitte
 * @date 27/05/2022
 * @description Test class for ExternalNotifierEventsServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class ExternalNotifierEventsServiceImplTest {
    private static final String EXTERNAL_NOTIFIER_EVENT_TABLET_CASE_INSERT_TOPIC = 'TABLET_CASE_INSERT';
    private static final String PAYLOAD_1 = 'PAYLOAD 1';
    private static final String PAYLOAD_2 = 'PAYLOAD 2';

    /**
     * @description To test creation of External Notifier events on publishEvents method call
     * with UOW instance and payload.
     */
    @isTest
    private static void testWhenPublishEventsCalledWithUOWAndPayloadThenExternalNotifierEventPublished() {
        List<TabletCaseEntry> tabletCaseEntries = new List<TabletCaseEntry>();
        TabletCaseEntry tabletCaseEntry = new TabletCaseEntry(
            fflib_IDGenerator.generate(WorkStep.SObjectType),
            fflib_IDGenerator.generate(WorkOrder.SObjectType)
        );
        tabletCaseEntries.add(tabletCaseEntry);
        Map<String, String> mockPayload = new Map<String, String>{
            EXTERNAL_NOTIFIER_EVENT_TABLET_CASE_INSERT_TOPIC => JSON.serialize(tabletCaseEntries)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        ExternalNotifierEventsService.publishEvents(mockPayload, mockUOW);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test creation of External Notifier events on publishEvents method
     * call with payload.
     */
    @isTest
    private static void testWhenPublishEventsCalledWithPayloadThenExternalNotifierEventPublished() {
        Set<TabletCaseEntry> tabletCaseEntries = new Set<TabletCaseEntry>();
        TabletCaseEntry tabletCaseEntry = new TabletCaseEntry(
            fflib_IDGenerator.generate(WorkStep.SObjectType),
            fflib_IDGenerator.generate(WorkOrder.SObjectType)
        );
        tabletCaseEntries.add(tabletCaseEntry);
        Map<String, String> mockPayload = new Map<String, String>{
            EXTERNAL_NOTIFIER_EVENT_TABLET_CASE_INSERT_TOPIC => JSON.serialize(tabletCaseEntries)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        ExternalNotifierEventsService.publishEvents(mockPayload);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test creation of multiple External Notifier events on publishEvents method
     * call with list of payloads, and only 1 commit.
     */
    @isTest
    private static void testWhenPublishEventsFromListCalledWithPayloadsThenExternalNotifierEventPublished() {
        List<String> payloadList = new List<String>();
        payloadList.add(PAYLOAD_1);
        payloadList.add(PAYLOAD_2);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        ExternalNotifierEventsService.publishEventsFromList(EXTERNAL_NOTIFIER_EVENT_TABLET_CASE_INSERT_TOPIC, payloadList);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
                .registerPublishAfterSuccessTransaction(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test External Notifier event is not published on publishEvents method
     * called with UOW instance and payload as null.
     */
    @isTest
    private static void testWhenPublishEventsCalledWithUOWAndNullPayloadThenExternalNotifierEventNotPublished() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        ExternalNotifierEventsService.publishEvents(null, mockUOW);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test External Notifier event is not published on publishEvents method call with
     * payload as null.
     */
    @isTest
    private static void testWhenPublishEventsCalledWithNullPayloadThenExternalNotifierEventNotPublished() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        ExternalNotifierEventsService.publishEvents(null);
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

		ExternalNotifierEventsServiceImpl.genericLogList.add(
            				ExternalNotifierEventsServiceImpl.getGenericLog().logException(commitException));
        ExternalNotifierEventsServiceImpl.publishGenericLog();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();

    }
}