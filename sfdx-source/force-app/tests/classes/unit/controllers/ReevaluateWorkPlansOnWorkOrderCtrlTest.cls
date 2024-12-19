/**
 * @author Deloitte
 * @date 13/07/2022
 * @description Test class for ReevaluateWorkPlansOnWorkOrderController class.
 * Suppressed Warnings since mock verify method does not require system assert statements
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class ReevaluateWorkPlansOnWorkOrderCtrlTest {
    /**
     * @description To test reevaluateWorkPlans method from ReevaluateWorkPlansOnWorkOrderService class
     * is called when parent Workorder Id is passed.
     */
    @isTest
    private static void testWhenWorkOrderIdReceivedThenExpectedServiceCalledSuccessfully() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IReevaluateWorkPlansOnWorkOrderService reevaluateWorkPlansOnWorkOrderService = (IReevaluateWorkPlansOnWorkOrderService) mocks.mock(
            IReevaluateWorkPlansOnWorkOrderService.class
        );
        Application.SERVICE.setMock(
            IReevaluateWorkPlansOnWorkOrderService.class,
            reevaluateWorkPlansOnWorkOrderService
        );
        Test.startTest();
        ReevaluateWorkPlansOnWorkOrderController.reevaluateWorkPlans(parentWorkOrderId);
        Test.stopTest();
        ((IReevaluateWorkPlansOnWorkOrderService) mocks.verify(
                reevaluateWorkPlansOnWorkOrderService,
                1
            ))
            .reevaluateWorkPlans(parentWorkOrderId);
    }
}