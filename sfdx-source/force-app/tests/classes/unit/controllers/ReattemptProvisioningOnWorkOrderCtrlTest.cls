/**
 * @author atg
 * @date 08/08/2022
 * @description Test class for ReattemptProvisioningOnWorkOrderCtrl class.
 * Suppressed Warnings since mock verify method does not require system assert statements
 */
@isTest(seeAllData=false)
@SuppressWarnings(
    'PMD.ApexUnitTestClassShouldHaveAsserts, PMD.ReattemptProvisioningOnWorkOrderCtrlTest'
)
public class ReattemptProvisioningOnWorkOrderCtrlTest {
    /**
     * @description To test reattemptProvisioning method from ReattemptProvisioningService class
     * is called when parent WorkOrder Id is passed.
     */
    @isTest
    private static void testWhenWorkPlanIdReceivedThenExpectedServiceCalledSuccessfully() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IReattemptProvisioningService reattemptProvisioningService = (IReattemptProvisioningService) mocks.mock(
            IReattemptProvisioningService.class
        );
        Application.SERVICE.setMock(
            IReattemptProvisioningService.class,
            reattemptProvisioningService
        );
        Test.startTest();
        ReattemptProvisioningOnWorkOrderCtrl.reattemptProvisioning(parentWorkOrderId);
        Test.stopTest();
        ((IReattemptProvisioningService) mocks.verify(reattemptProvisioningService, 1))
            .reattemptProvisioningOnWorkOrder(parentWorkOrderId);
    }
}