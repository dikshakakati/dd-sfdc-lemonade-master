/**
 * @description Domain class for ApplicationBindings
 * @author Scott McClung
 * @date 2023-02-28
 */
public without sharing class ApplicationBindings extends fflib_Objects implements IApplicationBindings {
    /**
     * @description This method is used to return the IApplicationBindings interface
     * @param lstApplicationBindings - ApplicationBindings record list
     * @return IApplicationBindings - Returns IApplicationBindings Interface
     */
    public static IApplicationBindings newInstance( List<ApplicationBinding> lstApplicationBindings ) {
        return (IApplicationBindings) new ApplicationBindings( lstApplicationBindings );
    }
    /**
     * @description constructor for object list to initialize
     * @param objectList
     */
    public ApplicationBindings( List<ApplicationBinding> objectList ) {
        super( objectList );
    }
    /**
     * @description Default constructor for the class
     * @return List<ApplicationBinding>
     */
    public List<ApplicationBinding> getApplicationBindings() {
        return (List<ApplicationBinding>) getObjects();
    }

    /**
     * @description filter the bindings by application type.
     * @param type
     * @return IApplicationBindings
     */
    public IApplicationBindings filteredByApplicationBindingType( ApplicationBindingType type ) {
        List<ApplicationBinding> lstBindings = new List<ApplicationBinding>();
        for( ApplicationBinding binding : getApplicationBindings() ) {
            if(type === binding.getApplicationType()) {
                lstBindings.add(binding);
            }
        }
        return ApplicationBindings.newInstance(lstBindings);
    }

    /**
     * @description return list of binding sobjects
     * @return List<SObjectType>
     */
    public List<SObjectType> getBindingSObjectsType() {
        List<SObjectType> lstSObjects = new List<SObjectType>();
        for( ApplicationBinding binding : getApplicationBindings() ) {
            Schema.SObjectType bindingSObjectType = (Schema.SObjectType) binding.getBindingObject();
            if( bindingSObjectType == null ) {
                continue;
            }
            lstSObjects.add( bindingSObjectType );
        }
        return lstSObjects;
    }

     /**
     * @description returns implementations by binding type
     * @return Map<System.Type, System.Type>
     */
    public Map<System.Type, System.Type> getImplementationsByBindingType() {
        Map<System.Type, System.Type> mapImplementationsByBindingType = new Map<System.Type, System.Type>();
        for( ApplicationBinding binding : getApplicationBindings() ) {
            System.Type bindingType = binding.getBindingType();
            System.Type implementationType = binding.getImplementationType();
            if(bindingType == null || implementationType == null){
                continue;
            }
            mapImplementationsByBindingType.put( bindingType, binding.getImplementationType() );
        }
        return mapImplementationsByBindingType;
    }

     /**
     * @description return implmenetations by binding object.
     * @param
     * @return Map<Object, System.Type>
     */
    public Map<Object, System.Type> getImplementationsByBindingObject() {
        Map< Object, System.Type> mapImplementationsByBindingType = new Map<Object, System.Type>();
        for( ApplicationBinding binding : getApplicationBindings() ) {
            Object bindingObject = binding.getBindingObject();
            System.Type implementationType = binding.getImplementationType();
            if( bindingObject == null || implementationType == null) {
                continue;
            }
            mapImplementationsByBindingType.put( bindingObject, binding.getImplementationType() );
        }
        return mapImplementationsByBindingType;
    }

     /**
     * @description return implementation by sobject type
     * @return Map<SObjectType, System.Type>
     */
    public Map<SObjectType, System.Type> getImplementationsByBindingSObjectType() {
        Map< SObjectType, System.Type> mapImplementationsByBindingType = new Map<SObjectType, System.Type>();
        for( ApplicationBinding binding : getApplicationBindings() ) {
            Schema.SObjectType bindingSObjectType = (Schema.SObjectType) binding.getBindingObject();
            System.Type implementationType = binding.getImplementationType();
            if( bindingSObjectType == null || implementationType == null) {
                continue;
            }
            mapImplementationsByBindingType.put( bindingSObjectType, binding.getImplementationType() );
        }
        return mapImplementationsByBindingType;
    }
}