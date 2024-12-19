/**
 * @description Service class for fetching the application bindings by filter criteria
 * @author DoorDash
 * @date 2023-10-05
 */
public with sharing class ApplicationBindingService {

	private static IApplicationBindingService service() {
        return new ApplicationBindingServiceImpl();
    }
    /**
     * @description Returns the (S)Objects corresponding to the application Binding Type value selected.
     * @param appBindingType
     * @return List<SObjectType>
     */
   	public static List<SObjectType> getBindingSObjects(ApplicationBindingType appBindingType){
		return service().setAppBindingType( appBindingType ).getBindingSObjects();
	}
     /**
     * @description returns implementations by binding type corresponding application Binding Type value selected.
     * @param appBindingType
     * @return Map<System.Type, System.Type>
     */
    public static Map<System.Type, System.Type> getBindingsByType(ApplicationBindingType appBindingType){
		return service().setAppBindingType( appBindingType ).getBindingsByType();
	}
     /**
     * @description return implementation by sobject type corresponding to the application Binding Type value selected
     * @param appBindingType
     * @return Map<SObjectType, System.Type>
     */
    public static Map<SObjectType, System.Type> getBindingsBySObjectType(ApplicationBindingType appBindingType){
		return service().setAppBindingType( appBindingType ).getBindingsBySObjectType();
	}
     /**
     * @description return implmenetations by binding object corresponding to the application Binding Type value selected
     * @param appBindingType
     * @return Map<Object, System.Type>
     */
    public static Map<Object, System.Type> getBindingsByObject(ApplicationBindingType appBindingType){
		return service().setAppBindingType( appBindingType ).getBindingsByObject();
	}
    /**
     * @description return implementation class if appbinding type and app bindings passed for further customization.
     * @param appBindingType
     * @param appBindings
     * @return ApplicationBindingServiceImpl
     */
    public static ApplicationBindingServiceImpl setAppBindingType(ApplicationBindingType appBindingType, List<ApplicationBinding> appBindings){
		return service().setAppBindingType( appBindingType,  appBindings);
	}
}