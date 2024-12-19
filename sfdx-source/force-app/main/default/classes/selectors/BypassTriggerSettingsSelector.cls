/**
 * @author Deloitte
 * @date 01/03/2022
 * @description Selector Class for Bypass_Trigger_Setting__mdt custom metadata
 */
public inherited sharing class BypassTriggerSettingsSelector extends fflib_SObjectSelector implements IBypassTriggerSettingsSelector {
    /**
     * @description default constructor for the class
     * @return IBypassTriggerSettingsSelector - interface of IBypassTriggerSettingsSelector
     */
    public static IBypassTriggerSettingsSelector newInstance() {
        return (IBypassTriggerSettingsSelector) Application.Selector.newInstance(
            Bypass_Trigger_Setting__mdt.SObjectType
        );
    }

    /**
     * @description override default getSObjectType method
     * @return SObjectType - object type of metadata
     */
    public Schema.SObjectType getSObjectType() {
        return Bypass_Trigger_Setting__mdt.SObjectType;
    }

    /**
     * @description It is used for getting the fields on Bypass_Trigger_Setting__mdt custom metadata.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Bypass_Trigger_Setting__mdt.Object_Name__c,
            Bypass_Trigger_Setting__mdt.Before_Insert__c,
            Bypass_Trigger_Setting__mdt.Before_Delete__c,
            Bypass_Trigger_Setting__mdt.Before_Update__c,
            Bypass_Trigger_Setting__mdt.After_Insert__c,
            Bypass_Trigger_Setting__mdt.After_Delete__c,
            Bypass_Trigger_Setting__mdt.After_Update__c,
            Bypass_Trigger_Setting__mdt.After_Undelete__c,
            Bypass_Trigger_Setting__mdt.Permission_Name__c,
            Bypass_Trigger_Setting__mdt.Permission_Type__c
        };
    }

    /**
     * @description This method is for getting all field values for Bypass_Trigger_Setting__mdt
     * @return List<Bypass_Trigger_Setting__mdt> - List of metadata records with values
     */
    public List<Bypass_Trigger_Setting__mdt> getAllValues() {
        return Bypass_Trigger_Setting__mdt.getall().values();
    }
}