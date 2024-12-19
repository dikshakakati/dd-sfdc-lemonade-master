/**
 * @author Scott McClung
 * @date 2023-02-28
 * @description Selector Class for ApplicationBinding Custom Metadata Object
 */
@SuppressWarnings('PMD.ApexCRUDViolation')
public inherited sharing class ApplicationBindingsSelector extends fflib_SObjectSelector implements IApplicationBindingsSelector {
    /**
     * @description default constructor for the ApplicationBinding__mdt Selector class.
     * Because this selector is leveraged prior to the resolution of the Application Factory mapping,
     * it cannot depend on the Application Factory for resolution.  It has to new itself up.
     * @return IApplicationBindingsSelector - interface of ApplicationBindingsSelector
     */
    public static IApplicationBindingsSelector newInstance() {
        return (IApplicationBindingsSelector) new ApplicationBindingsSelector();
    }

    /**
     * @description This method is for getting the fields on ApplicationBinding__mdt object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            ApplicationBinding__mdt.Id,
            ApplicationBinding__mdt.MasterLabel,
            ApplicationBinding__mdt.DeveloperName,
            ApplicationBinding__mdt.ApplicationType__c,
            ApplicationBinding__mdt.BindingObject__c,
            ApplicationBinding__mdt.BindingObjectApiName__c,
            ApplicationBinding__mdt.BindingType__c,
            ApplicationBinding__mdt.ImplementationType__c
        };
    }

    /**
     * @description This method is used for getting Object type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return ApplicationBinding__mdt.SObjectType;
    }

    /**
     * @description Returns a map containing custom metadata records for the specific custom metadata type.
     * The map keys are the record DeveloperNames and the map values are the record sObjects.
     * @return Map<String, ApplicationBinding__mdt> - Custom metadata records
     */
    public Map<String, ApplicationBinding__mdt> getAll() {
        return ApplicationBinding__mdt.getAll();
    }

    /**
     * @description Returns a single custom metadata type record sObject for a specified record Id, DeveloperName, or API name.
     * @param idOrName
     * @return ApplicationBinding__mdt - Single record
     */
    public ApplicationBinding__mdt getInstance( String idOrName ) {
        return ApplicationBinding__mdt.getInstance( idOrName );
    }

    /**
     * @description Returns a list of all Application Binding records
     * @return List<ApplicationBinding__mdt> - returns list of metadata records
     */
    public List<ApplicationBinding__mdt> getAllValues() {
        return [select id, BindingObject__r.QualifiedApiName, MasterLabel, DeveloperName, Execution_order__c, ApplicationType__c, BindingObject__c,
        BindingObjectApiName__c, BindingType__c, ImplementationType__c from ApplicationBinding__mdt order by Execution_order__c asc limit 3000];
    }
}