/**
 * @description Custom implementation of the Selector Factory.
 * Override fflib_Application.SelectorFactory methods here for any custom behavior
 * @author Scott McClung
 * @date 2023-02-16
 */
public inherited sharing class ApplicationSelectorFactory extends fflib_Application.SelectorFactory {

    /**
     * @description Constructs a Selector Factory linking SObjectType's with classes
     * implementing the fflib_ISObjectSelector interface
     * @param selectorTypesBySObjectType - Map of Selector classes by SObjectType
     */
    public ApplicationSelectorFactory( Map<SObjectType, Type> selectorTypesBySObjectType ) {
        super( selectorTypesBySObjectType );
    }
}