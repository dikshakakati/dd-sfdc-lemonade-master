/**
 * @description Service class for fetching the application bindings by filter criteria
 * @author DoorDash
 * @date 2023-10-05
 */
public interface IApplicationBindingService {
    /**
     * @description instantiate factory class to fetch the bindings and returns the this class.
     * @param appBindingType
     * @return ApplicationBindingServiceImpl
     */
    ApplicationBindingServiceImpl setAppBindingType(ApplicationBindingType appBindingType);
     /**
     * @description return list of binding sobjects
     * @return List<SObjectType>
     */
	List<SObjectType> getBindingSObjects();
    /**
     * @description returns implementations by binding type
     * @return Map<System.Type, System.Type>
     */
    Map<System.Type, System.Type> getBindingsByType();
    /**
     * @description return implmenetations by binding object.
     * @param
     * @return Map<Object, System.Type>
     */
    Map<Object, System.Type> getBindingsByObject();
    /**
     * @description return implementation by sobject type
     * @return Map<SObjectType, System.Type>
     */
    Map<SObjectType, System.Type> getBindingsBySObjectType();
    /**
     * @description return implementation class if appbinding type and app bindings passed for further customization.
     * @param appBindingType
     * @param appBindings
     * @return ApplicationBindingServiceImpl
     */
    ApplicationBindingServiceImpl setAppBindingType(ApplicationBindingType appBindingType, List<ApplicationBinding> appBindings);
}