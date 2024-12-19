/**
 * @author Deloitte
 * @date 15/06/2022
 * @description Test class for AssignToQueueController class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class AssignToQueueControllerTest {
    private static final string GROUP_DEVELOPER_NAME = 'Test_COO_Queue';
    private static final string GROUP_NAME = 'Test COO Queue';
    private static final string GROUP_TYPE = 'Queue';

    /**
     * @description To test WorkPlan queues query filtered by QueuesSobject records.
     */
    @isTest
    private static void testWhenGetWorkPlanQueuesThenReturnRelatedQueues() {
        Id groupId = fflib_IDGenerator.generate(Group.SObjectType);
        List<Group> groups = new List<Group>{
            (Group) new Fake(Group.class)
                .setField(Group.DeveloperName, GROUP_DEVELOPER_NAME)
                .setField(Group.Name, GROUP_NAME)
                .setField(Group.Type, GROUP_TYPE)
                .setField(Group.Id, groupId)
                .toSObject()
        };
        List<List<Group>> workPlanQueues = new List<List<Group>>{ groups };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkPlansService workPlanService = (IWorkPlansService) mocks.mock(IWorkPlansService.class);
        mocks.startStubbing();
        mocks.when(workPlanService.getWorkPlanQueues()).thenReturn(workPlanQueues);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IWorkPlansService.class, workPlanService);
        Test.startTest();
        AssignToQueueController.getWorkPlanQueues();
        Test.stopTest();
        ((IWorkPlansService) mocks.verify(workPlanService, 1)).getWorkPlanQueues();
    }
}