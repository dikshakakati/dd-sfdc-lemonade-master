/**
 * @description Custom implementation of the Service Factory.
 * Override fflib_Application.ServiceFactory methods here for any custom behavior
 * @author Scott McClung
 * @date 2023-02-16
 */
public inherited sharing class ApplicationServiceFactory extends fflib_Application.ServiceFactory {
    /**
     * @description Constructs a simple Service Factory using a map of interfaces
     * to classes implementing the interface
     * @param serviceImplTypesByServiceInterfaceType - Map of service classes by the interface they implement
     */
    public ApplicationServiceFactory( Map<Type, Type> serviceImplTypesByServiceInterfaceType ) {
        super( serviceImplTypesByServiceInterfaceType );
    }
}