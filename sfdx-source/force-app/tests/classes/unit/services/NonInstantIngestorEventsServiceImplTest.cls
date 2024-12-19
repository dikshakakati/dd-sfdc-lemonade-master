/**
 * @author Deloitte
 * @date 06/04/2024
 * @description Test class for NonInstantIngestorEventsServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class NonInstantIngestorEventsServiceImplTest {
    /**
     * @description To test creation of Instant Ingestor Events on publishEvents method call
     * with UOW instance and payload.
     */
    @isTest
    private static void testWhenPublishEventsCalledWithUOWAndPayloadThenInstantIngestorEventPublished() {
        Set<Id> instantIngestorLogIds = new Set<Id>{
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType),
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType)
        };
        Map<String, String> mockPayload = new Map<String, String>{
            'SSMO_FALLOUT' => JSON.serialize(instantIngestorLogIds)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        NonInstantIngestionEventsService.publishEvents(mockPayload, mockUOW);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description It is used to test creation of Instant Ingestor Events on publishEvents method call with payload.
     */
    @isTest
    private static void testWhenPublishEventsCalledWithPayloadThenInstantIngestorEventPublished() {
        Set<Id> instantIngestorLogIds = new Set<Id>{
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType),
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType)
        };
        Map<String, String> mockPayload = new Map<String, String>{
            'SSMO_FALLOUT' => JSON.serialize(instantIngestorLogIds)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        NonInstantIngestionEventsService.publishEvents(mockPayload);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Instant Ingestor Event is not published on publishEvents method call with
     * UOW instance and payload as null.
     */
    @isTest
    private static void testWhenPublishEventsCalledWithUOWAndNullPayloadThenNotifierEventNotPublished() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        NonInstantIngestionEventsService.publishEvents(null, mockUOW);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description It is used to test Instant Ingestor Event is not published on publishEvents method call with
     * payload as null.
     */
    @isTest
    private static void testWhenPublishEventsCalledWithNullPayloadThenInstantIngestorEventNotPublished() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        NonInstantIngestionEventsService.publishEvents(null);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description It is used to test creation of Instant Ingestor Events on publishBulkEvents method call with payloads.
     */
    @isTest
    private static void testWhenPublishBulkEventsCalledWithPayloadThenInstantIngestorEventPublished() {
        List<String> mockMergedPayloads = new List<String>{
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType),
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType)
        };
        Map<String, List<String>> mockPayload = new Map<String, List<String>>{
            'SSMO_FALLOUT' => mockMergedPayloads
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        NonInstantIngestionEventsService.publishBulkEvents(mockPayload);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description It is used to test Instant Ingestor Event is not published on publishBulkEvents method call with
     * payload as null.
     */
    @isTest
    private static void testWhenPublishBulkEventsCalledWithNullPayloadThenInstantIngestorEventNotPublished() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        NonInstantIngestionEventsService.publishBulkEvents(null);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }
    /**
     * @description It is used to test Generic log call with list of payloads, and only 1 commit.
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

        NonInstantIngestorEventsServiceImpl.genericLogList.add(
            NonInstantIngestorEventsServiceImpl.getGenericLog().logException(commitException)
        );
        NonInstantIngestorEventsServiceImpl.publishGenericLog();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
}