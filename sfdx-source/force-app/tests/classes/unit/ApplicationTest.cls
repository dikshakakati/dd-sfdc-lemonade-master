/**
 * @author Deloitte
 * @date 06/07/2024
 * @description Test class for Application class.
 * It is created to prevent running all the test classes when application class is modified.
 */
@isTest(SeeAllData=false)
public class ApplicationTest {
    /**
     * @description To test Service, Unit Of Work, Selector and Domain factories are initiated
     * from Application class.
     */
    @isTest
    private static void testWhenApplicationFactoriesAreCalledThenReturnFactoryInstances() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IApplicationBindingService mockApplicationBindingService = (IApplicationBindingService) mocks.mock(
            IApplicationBindingService.class
        );
        Application.SERVICE.setMock(
            IApplicationBindingService.class,
            mockApplicationBindingService
        );

        System.assertEquals(Application.UNITOFWORK.newInstance() == null, false, '');
        System.assertEquals(Application.SERVICE == null, false, '');
        System.assertEquals(Application.SELECTOR == null, false, '');
        System.assertEquals(Application.DOMAIN == null, false, '');
        System.assertEquals(Application.NOTIFIER_EVENT == null, false, '');
        System.assertEquals(Application.ONBOARDING_AND_ACTIVATIONS_EVENT == null, false, '');
    }
}