/**
 * @author Deloitte
 * @date 06/13/2022
 * @description Selector Class for Notifier Event Binding custom metadata
 */
public inherited sharing class NotifierEventBindingsSelector extends fflib_SObjectSelector implements INotifierEventBindingsSelector {
    /**
     * @description default constructor for the class
     * @return INotifierEventBindingsSelector - interface of INotifierEventBindingsSelector
     */
    public static INotifierEventBindingsSelector newInstance() {
        return (INotifierEventBindingsSelector) Application.Selector.newInstance(
            Notifier_Event_Binding__mdt.SObjectType
        );
    }

    /**
     * @description override default getSObjectType method
     * @return SObjectType - object type of metadata
     */
    public Schema.SObjectType getSObjectType() {
        return Notifier_Event_Binding__mdt.SObjectType;
    }

    /**
     * @description This method is for getting all field values for Notifier_Event_Binding__mdt
     * @return List<Notifier_Event_Binding__mdt> - List of metadata records with values
     */
    public List<Notifier_Event_Binding__mdt> getAllValues() {
        return Notifier_Event_Binding__mdt.getAll().values();
    }

    /**
     * @description This method is for getting the fields of Notifier_Event_Binding__mdt
     * @return List<Schema.SObjectField>- Notifier_Event_Binding__mdt fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Notifier_Event_Binding__mdt.Topic__c,
            Notifier_Event_Binding__mdt.Class_Name__c,
            Notifier_Event_Binding__mdt.Scope_Size__c
        };
    }
}