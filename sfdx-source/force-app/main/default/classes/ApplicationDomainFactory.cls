/**
 * @description Custom implementation of the Domain Factory.
 * Override any of the fflib_Application.DomainFactory methods here to create custom behavior
 * @author Scott McClung
 * @date 2023-02-16
 */
public inherited sharing class ApplicationDomainFactory extends fflib_Application.DomainFactory {
    /**
     * @description Constructs a Domain factory, using an instance of the Selector Factory
     *   and a map of objects by object type
     * @param selectorFactory - e.g. Application.Selector
     * @param constructorTypeByObject - Map of Domain classes by Object type
     */
    public ApplicationDomainFactory( fflib_Application.SelectorFactory selectorFactory,
        Map<Object, Type> constructorTypeByObject ) {
        super( selectorFactory, constructorTypeByObject );
    }

    /**
     * @description Constructs a Domain factory, using an instance of the Selector Factory
     *   and a map of classes implementing fflib_ISObjectDomain by SObjectType
     * @param selectorFactory - e.g. Application.Selector
     * @param sObjectByDomainConstructorType - Map of Domain classes by SObjectType
     */
    public ApplicationDomainFactory( fflib_Application.SelectorFactory selectorFactory,
        Map<SObjectType, Type> sObjectByDomainConstructorType ) {
        super( selectorFactory, sObjectByDomainConstructorType );
    }
}