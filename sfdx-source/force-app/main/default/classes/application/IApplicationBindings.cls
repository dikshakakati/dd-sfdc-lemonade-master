/**
 * @description interface for ApplicationBindings class
 * @author Scott McClung
 * @date 2023-02-28
 */
public interface IApplicationBindings extends fflib_IObjects {
    /**
     * @description Default constructor for the class
     * @return List<ApplicationBinding>
     */
    List<ApplicationBinding> getApplicationBindings();
     /**
     * @description filter the bindings by application type.
     * @param type
     * @return IApplicationBindings
     */
    IApplicationBindings filteredByApplicationBindingType(ApplicationBindingType type);
    /**
     * @description return list of binding sobjects
     * @return List<SObjectType>
     */
    List<SObjectType> getBindingSObjectsType();
    /**
     * @description returns implementations by binding type
     * @return Map<System.Type, System.Type>
     */
    Map<System.Type, System.Type> getImplementationsByBindingType();
    /**
     * @description return implmenetations by binding object.
     * @param
     * @return Map<Object, System.Type>
     */
    Map<Object, System.Type> getImplementationsByBindingObject();
    /**
     * @description return implementation by sobject type
     * @return Map<SObjectType, System.Type>
     */
    Map<SObjectType, System.Type> getImplementationsByBindingSObjectType();
}