/**
 * @description factory class for fetching the custom metadata values.
 * @author DoorDash
 * @date 2023-10-05
 */
public class ApplicationBindingsProviderFactory {
	private static IApplicationBindings bindings;
    /**
     * @description instance class for fetching the bindings if already not fetched.
     * @return IApplicationBindings
     */
    public static IApplicationBindings getInstance() {
        if (bindings == null) {
            bindings = createInstance();
        }
        return bindings;
    }
    /**
     * @description instance class for fetch application binding value from custom metadata.
     * @return IApplicationBindings
     */
    private static IApplicationBindings createInstance() {
        List<ApplicationBinding> lstBindings = new List<ApplicationBinding>();        
        for (ApplicationBinding__mdt objBinding : ApplicationBindingsSelector.newInstance().getAllValues()) {           
            lstBindings.add(new ApplicationBinding(objBinding));
        }
        return ApplicationBindings.newInstance(lstBindings);
    }
}