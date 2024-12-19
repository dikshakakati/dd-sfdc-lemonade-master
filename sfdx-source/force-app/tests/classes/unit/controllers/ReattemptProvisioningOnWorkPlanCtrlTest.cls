/**
 * @author atg
 * @date 08/08/2022
 * @description Test class for ReattemptProvisioningOnWorkPlanCtrl class.
 * Suppressed Warnings since mock verify method does not require system assert statements
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class ReattemptProvisioningOnWorkPlanCtrlTest {
    /**
     * @description To test reattemptProvisioning method from ReattemptProvisioningService class
     * is called when parent WorkPlan Id is passed.
     */
    @isTest
    private static void testWhenWorkPlanIdReceivedThenExpectedServiceCalledSuccessfully() {
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IReattemptProvisioningService reattemptProvisioningService = (IReattemptProvisioningService) mocks.mock(
            IReattemptProvisioningService.class
        );
        Application.SERVICE.setMock(
            IReattemptProvisioningService.class,
            reattemptProvisioningService
        );
        Test.startTest();
        ReattemptProvisioningOnWorkPlanCtrl.reattemptProvisioning(parentWorkPlanId);
        Test.stopTest();
        ((IReattemptProvisioningService) mocks.verify(reattemptProvisioningService, 1))
            .reattemptProvisioning(parentWorkPlanId);
    }
}