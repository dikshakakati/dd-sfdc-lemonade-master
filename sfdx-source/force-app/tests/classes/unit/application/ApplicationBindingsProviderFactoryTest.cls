/**
 * @description test class for ApplicationBindingsProviderFactory
 * @author DoorDash
 * @date 2023-10-05
 */
@isTest(seeAllData=false)
public class ApplicationBindingsProviderFactoryTest {
	/**
     * @description test method for when GetInstance method called return list of app bindings.
     */
    @isTest
    static void testWhenGetInstanceMethodCalledThenReturnInstanceOfapplicationBindings(){
        IApplicationBindings appBindings = ApplicationBindingsProviderFactory.getInstance();
        List<ApplicationBinding__mdt> allEventsData = ApplicationBindingsSelector.newInstance()
            .getAllValues();
        System.assertEquals(allEventsData.size(), appBindings.getApplicationBindings().size(), 'application bindings count not matching');
    }
}