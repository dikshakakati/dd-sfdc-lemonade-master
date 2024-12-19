/**
 * @author Deloitte
 * @date 05/09/2024
 * @description Test class for EmailOutboundIntegrationsEventsSrvcImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class EmailOutboundEventsSrvcImplTest {
    private static final String EVENT_TOPIC_EMAIL_OUTBOUND_INTEGRATION = 'EMAIL_OUTBOUND_INTEGRATION';
    private static final String MOCK_ERROR = 'Error occured';
    /**
     * @description To test creation of Email outbound events on publishEvents method call
     * with UOW instance and payload.
     */
    @isTest
    private static void testWhenPublishEventsCalledWithUOWAndPayloadThenEmailOutboundEventPublished() {
        Set<Id> mockRecordIds = new Set<Id>{
            fflib_IDGenerator.generate(Opportunity.SObjectType),
            fflib_IDGenerator.generate(Opportunity.SObjectType)
        };
        Map<String, String> mockPayload = new Map<String, String>{
            EVENT_TOPIC_EMAIL_OUTBOUND_INTEGRATION => JSON.serialize(mockRecordIds)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        EmailOutboundIntegrationsEventsService.publishEvents(mockPayload, mockUOW);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test creation of Email outbound events on publishEvents method call with payload.
     */
    @isTest
    private static void testWhenPublishEventsCalledWithPayloadThenEmailOutboundEventPublished() {
        Set<Id> mockRecordIds = new Set<Id>{
            fflib_IDGenerator.generate(Opportunity.SObjectType),
            fflib_IDGenerator.generate(Opportunity.SObjectType)
        };
        Map<String, String> mockPayload = new Map<String, String>{
            EVENT_TOPIC_EMAIL_OUTBOUND_INTEGRATION => JSON.serialize(mockRecordIds)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        EmailOutboundIntegrationsEventsService.publishEvents(mockPayload);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Email outbound event is not published on publishEvents method call with
     * UOW instance and payload as null.
     */
    @isTest
    private static void testWhenPublishEventsCalledWithUOWAndNullPayloadThenEmailOutboundEventNotPublished() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        EmailOutboundIntegrationsEventsService.publishEvents(null, mockUOW);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test Email outbound event is not published on publishEvents method call with
     * payload as null.
     */
    @isTest
    private static void testWhenPublishEventsCalledWithNullPayloadThenEmailOutboundEventNotPublished() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        EmailOutboundIntegrationsEventsService.publishEvents(null);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test creation of Email outbound events on publishBulkEvents method call with payloads.
     */
    @isTest
    private static void testWhenPublishBulkEventsCalledWithPayloadThenEmailOutboundEventPublished() {
        List<String> mockMergedPayloads = new List<String>{
            fflib_IDGenerator.generate(Opportunity.SObjectType),
            fflib_IDGenerator.generate(Opportunity.SObjectType)
        };
        Map<String, List<String>> mockPayload = new Map<String, List<String>>{
            EVENT_TOPIC_EMAIL_OUTBOUND_INTEGRATION => mockMergedPayloads
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        EmailOutboundIntegrationsEventsService.publishBulkEvents(mockPayload);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Email outbound event is not published on publishBulkEvents method call with
     * payload as null.
     */
    @isTest
    private static void testWhenPublishBulkEventsCalledWithNullPayloadThenEmailOutboundEventNotPublished() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        EmailOutboundIntegrationsEventsService.publishBulkEvents(null);
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
        commitException.setMessage(MOCK_ERROR);

        EmailOutboundIntegrationsEventsSrvcImpl.genericLogList.add(
            EmailOutboundIntegrationsEventsSrvcImpl.getGenericLog().logException(commitException)
        );
        EmailOutboundIntegrationsEventsSrvcImpl.publishGenericLog();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
}