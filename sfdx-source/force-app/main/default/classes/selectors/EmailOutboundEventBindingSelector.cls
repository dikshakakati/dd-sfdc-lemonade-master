/**
 * @author Deloitte
 * @date 05/09/2024
 * @description Selector class to query Email outbound integration binding.
 */
public inherited sharing class EmailOutboundEventBindingSelector extends fflib_SObjectSelector implements IEmailOutboundEventBindingSelector {
    /**
     * @description default constructor for the class
     * @return IEmailOutboundEventBindingSelector - interface of IEmailOutboundEventBindingSelector
     */
    public static IEmailOutboundEventBindingSelector newInstance() {
        return (IEmailOutboundEventBindingSelector) Application.Selector.newInstance(
            Email_Outbound_Events_Binding__mdt.SObjectType
        );
    }

    /**
     * @description override default getSObjectType method
     * @return SObjectType - object type of metadata
     */
    public Schema.SObjectType getSObjectType() {
        return Email_Outbound_Events_Binding__mdt.SObjectType;
    }

    /**
     * @description This method is for getting all field values for Email_Outbound_Events_Binding__mdt
     * @return List<Email_Outbound_Events_Binding__mdt> - List of metadata records with values
     */
    public List<Email_Outbound_Events_Binding__mdt> getAllValues() {
        return Email_Outbound_Events_Binding__mdt.getAll().values();
    }

    /**
     * @description This method is for getting the fields of Email_Outbound_Events_Binding__mdt
     * @return List<Schema.SObjectField>- Email_Outbound_Events_Binding__mdt fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Email_Outbound_Events_Binding__mdt.Topic__c,
            Email_Outbound_Events_Binding__mdt.Class_Name__c,
            Email_Outbound_Events_Binding__mdt.Scope_Size__c
        };
    }
}