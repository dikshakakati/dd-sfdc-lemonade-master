
/**
 * @description Test class for MDSSyncEventsHandler
 */
@isTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class MDSSyncEventsHandlerTest {

    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenMdsSyncEventPublishedThenServiceInvoked() {
        Id intReqId = fflib_IDGenerator.generate(Integration_Request__c.SObjectType);
        List<MDS_Sync_Event__e> mdsSyncEvents = new List<MDS_Sync_Event__e>{
            new MDS_Sync_Event__e(
                Integration_Request_Id__c = intReqId
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        IMDSSyncEventsService serviceMock = (IMDSSyncEventsService) mocks.mock(
            IMDSSyncEventsService.class
        );
        Application.SERVICE.setMock(IMDSSyncEventsService.class, serviceMock);

        Test.startTest();

        EventBus.publish(mdsSyncEvents);

        Test.stopTest();

        ((IMDSSyncEventsService) mocks.verify(serviceMock, 1))
            .processMDSUpdates(new Set<Id>{intReqId});
    }
}