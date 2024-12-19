/**
 * @description Service implementation class for fetching the application bindings by filter criteria
 * @author DoorDash
 * @date 2023-10-05
 */
public with sharing class ApplicationBindingServiceImpl implements IApplicationBindingService{
	private IApplicationBindings bindings;
    private ApplicationBindingType applicationBindingType;
     /**
     * @description instantiate factory class to fetch the bindings and returns the this class.
     * @param appBindingType
     * @return ApplicationBindingServiceImpl
     */
  	public ApplicationBindingServiceImpl setAppBindingType(ApplicationBindingType appBindingType) {
        this.applicationBindingType = appBindingType;
        this.bindings = ApplicationBindingsProviderFactory.getInstance();
        return this;
    }
    /**
     * @description return implementation class if appbinding type and app bindings passed for further customization.
     * @param appBindingType
     * @param appBindings
     * @return ApplicationBindingServiceImpl
     */
    public ApplicationBindingServiceImpl setAppBindingType(ApplicationBindingType appBindingType, List<ApplicationBinding> appBindings) {
        this.applicationBindingType = appBindingType;
        this.bindings = ApplicationBindings.newInstance(appBindings);
        return this;
    }
    /**
     * @description return list of binding sobjects
     * @return List<SObjectType>
     */
    public List<SObjectType> getBindingSObjects() {
        return filterBindings().getBindingSObjectsType();
    }
     /**
     * @description returns implementations by binding type
     * @return Map<System.Type, System.Type>
     */
    public Map<System.Type, System.Type> getBindingsByType() {
        return filterBindings().getImplementationsByBindingType();
    }
     /**
     * @description return implmenetations by binding object.
     * @param
     * @return Map<Object, System.Type>
     */
    public Map<Object, System.Type> getBindingsByObject() {
        return filterBindings().getImplementationsByBindingObject();
    }
    /**
     * @description return implementation by sobject type
     * @return Map<SObjectType, System.Type>
     */
    public Map<SObjectType, System.Type> getBindingsBySObjectType() {
        return filterBindings().getImplementationsByBindingSObjectType();
    }
    /**
     * @description filter the bindings by application type.
     * @return IApplicationBindings
     */
    private IApplicationBindings filterBindings() {
        return bindings.filteredByApplicationBindingType(applicationBindingType);
    }
}