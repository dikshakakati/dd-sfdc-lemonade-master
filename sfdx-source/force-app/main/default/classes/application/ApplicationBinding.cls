/**
 * @description Resolves an ApplicationBinding__mdt record into the mapped implementation
 * @author Scott McClung
 * @date 2023-02-28
 */
public virtual class ApplicationBinding implements IApplicationBinding {
    protected ApplicationBindingType applicationBindingType { get; private set; }
    protected Object bindingObject { get; private set; }
    protected System.Type bindingType { get; private set; }
    protected System.Type implementationType { get; private set; }
    protected ApplicationBinding__mdt bindingRecord { get; private set; }
	private static Map<String, ApplicationBindingType> stringToEnumMap = new Map<String, ApplicationBindingType>{
    'Domain' => ApplicationBindingType.DOMAIN,
    'Service' => ApplicationBindingType.SERVICE,
    'Selector' => ApplicationBindingType.SELECTOR,
    'UnitOfWork' => ApplicationBindingType.UNITOFWORK
	};
    /**
     * @description Constructor
     * @param bindingRecord
     */
    public ApplicationBinding( ApplicationBinding__mdt bindingRecord ) {
        if( bindingRecord == null ) {
            throw new DeveloperException( 'ApplicationBinding constructor requires an instance of ApplicationBinding__mdt.' );
        }
        this.bindingRecord = bindingRecord;
        this.applicationBindingType = parseApplicationBindingType( bindingRecord );
        this.bindingObject = parseBindingObject( bindingRecord );
        this.bindingType = parseBindingType( bindingRecord );
        this.implementationType = parseImplementationType( bindingRecord );
    }
	
    /**
     * @description Returns the ApplicationBindingType enum corresponding to the ApplicationBindingType on the
     * binding record.  Possible values: ApplicationBindingType.SERVICE, ApplicationBindingType.SELECTOR,
     * ApplicationBindingType.DOMAIN, ApplicationBindingType.UNITOFWORK
     * @return ApplicationBindingType
     */
    public virtual ApplicationBindingType getApplicationType() {
        return applicationBindingType;
    }

    /**
     * @description Returns the (S)Object corresponding to the binding object value selected on the binding record
     * @return Object
     */
    public virtual Object getBindingObject() {
        return this.bindingObject;
    }
    /**
     * @description Returns the System.Type corresponding to the binding type value selected on the binding record
     * @return System.Type
     */
    public virtual System.Type getBindingType() {
        return this.bindingType;
    }

    /**
     * @description Returns the System.Type corresponding to the implementation type value selected on the binding record
     * @return System.Type
     */
    public virtual System.Type getImplementationType() {
        return implementationType;
    }

    /**
     * @description Returns an ApplicationBindingType enum based on the ApplicationBindingType value on the
     * binding record
     * @param bindingRecord
     * @return ApplicationBindingType enum
     */
    private ApplicationBindingType parseApplicationBindingType( ApplicationBinding__mdt bindingRecord ) {
        if( String.isBlank( bindingRecord.ApplicationType__c ) )
        {
            return null;
        }
        if(!stringToEnumMap.containsKey(bindingRecord.ApplicationType__c)){
            throw new DeveloperException(
                String.format(
                    'Unable to identify binding type {0} referenced by binding {1}',
                    new List<String>{ bindingRecord.ApplicationType__c, bindingRecord.DeveloperName }
                )
            );
        }
        return stringToEnumMap.get(bindingRecord.ApplicationType__c);
    }

    /**
     * @description Returns an (S)Object based on the Binding Object value on the binding record
     * @param bindingRecord
     * @return Object
     */
    private Object parseBindingObject( ApplicationBinding__mdt bindingRecord ) {
        if( String.isBlank( bindingRecord.BindingObject__c ) && String.isBlank( bindingRecord.BindingObjectApiName__c ) )
        {
            return null;
        }
        String bindingObjectApiName = string.isNotBlank (bindingRecord.BindingObject__c )
            && string.isNotBlank ( bindingRecord.BindingObject__r.QualifiedApiName )
            ? bindingRecord.BindingObject__r.QualifiedApiName.toLowerCase().trim()
            : bindingRecord.BindingObjectApiName__c.toLowerCase().trim();
        try{
            // Assume its an SObjectType
            List<Schema.DescribeSObjectResult> schemaDescribes = Schema.describeSObjects( new List<String>{ bindingObjectApiName } );
            if( schemaDescribes.size() == 1 ) {
                return schemaDescribes.get( 0 ).getSObjectType();
            }
        } catch (Exception ex){
            throw new DeveloperException(
                String.format(
                    'Failed to find (S)Object {0} referenced by binding {1}',
                    new List<String>{ bindingObjectApiName, bindingRecord.DeveloperName }
                )
            );
        }
        return null;
    }

    /**
     * @description Returns an System Type based on the Binding Type value on the binding record
     * @param bindingRecord
     * @return System.Type
     */
    private System.Type parseBindingType( ApplicationBinding__mdt bindingRecord ) {
        if( String.isBlank( bindingRecord.BindingType__c ) )
        {
            return null;
        }
        System.Type systemType = System.Type.forName( bindingRecord.BindingType__c );
        if( systemType == null ) {
            throw new DeveloperException(
                String.format(
                    'Unable to find {0} referenced by binding {1}',
                    new List<String>{ bindingRecord.BindingType__c, bindingRecord.DeveloperName }
                )
            );
        }
        return systemType;
    }

    /**
     * @description Returns an System Type based on the Implementation Type value on the binding record
     * @param bindingRecord
     * @return System.Type
     */
    private System.Type parseImplementationType( ApplicationBinding__mdt bindingRecord ) {
        if( String.isBlank( bindingRecord.ImplementationType__c ) )
        {
            return null;
        }
        System.Type systemType = System.Type.forName( bindingRecord.ImplementationType__c );
        if( systemType == null ) {
            throw new DeveloperException(
                String.format(
                    'Unable to find {0} referenced by binding {1}',
                    new List<String>{ bindingRecord.ImplementationType__c, bindingRecord.DeveloperName }
                )
            );
        }
        return systemType;
    }

    /**
     * @description class for handling excepitons
     */
    public class DeveloperException extends Exception {}
}