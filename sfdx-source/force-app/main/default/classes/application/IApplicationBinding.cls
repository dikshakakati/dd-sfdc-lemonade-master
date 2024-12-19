/**
 * @description interface for ApplicationBinding
 * @author Scott McClung
 * @date 2023-02-28
 */
public interface IApplicationBinding {
     /**
     * @description Returns the ApplicationBindingType enum corresponding to the ApplicationBindingType on the
     * binding record.  Possible values: ApplicationBindingType.SERVICE, ApplicationBindingType.SELECTOR,
     * ApplicationBindingType.DOMAIN, ApplicationBindingType.UNITOFWORK
     * @return ApplicationBindingType
     */
    ApplicationBindingType getApplicationType();
    /**
     * @description Returns the (S)Object corresponding to the binding object value selected on the binding record
     * @return Object
     */
    Object getBindingObject();
     /**
     * @description Returns the System.Type corresponding to the binding type value selected on the binding record
     * @return System.Type
     */
    System.Type getBindingType();
    /**
     * @description Returns the System.Type corresponding to the implementation type value selected on the binding record
     * @return System.Type
     */
    System.Type getImplementationType();
}