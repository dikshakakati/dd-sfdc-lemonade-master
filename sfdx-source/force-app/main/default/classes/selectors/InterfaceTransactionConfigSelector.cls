/**
 * @author Deloitte
 * @date 04/23/2024
 * @description Selector class for Interface Transaction Configurations custom metadata type.
 */
public with sharing class InterfaceTransactionConfigSelector extends fflib_SObjectSelector implements IInterfaceTransactionConfigSelector {
    /**
     * @description default constructor for the class
     * @return IInterfaceTransactionConfigSelector - interface of InterfaceTransactionConfigSelector
     */
    public static IInterfaceTransactionConfigSelector newInstance() {
        return (IInterfaceTransactionConfigSelector) Application.Selector.newInstance(
            Interface_Transaction_Configuration__mdt.SObjectType
        );
    }

    /**
     * @description override default getSObjectType method
     * @return SObjectType - object type of metadata
     */
    public Schema.SObjectType getSObjectType() {
        return Interface_Transaction_Configuration__mdt.SObjectType;
    }

    /**
     * @description This method is for getting the fields on Interface_Transaction_Configuration__mdt
     * @return List<Schema.SObjectField>- Interface_Transaction_Configuration__mdt fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Interface_Transaction_Configuration__mdt.DeveloperName,
            Interface_Transaction_Configuration__mdt.Enable_Logging__c,
            Interface_Transaction_Configuration__mdt.Enable_Retry__c,
            Interface_Transaction_Configuration__mdt.Interface_Transaction_Name__c,
            Interface_Transaction_Configuration__mdt.Is_Active__c,
            Interface_Transaction_Configuration__mdt.Label,
            Interface_Transaction_Configuration__mdt.Retry_Limit__c,
            Interface_Transaction_Configuration__mdt.Service_Class_Name__c
        };
    }

    /**
     * @description It is used for getting the interface transaction configuration records.
     * @param interfaceTransactionNames
     * @return List<Interface_Transaction_Configuration__mdt>
     */
    public List<Interface_Transaction_Configuration__mdt> selectByInterfaceTransactionNames(
        Set<String> interfaceTransactionNames
    ) {
        List<Interface_Transaction_Configuration__mdt> result = Database.query(
            newQueryFactory()
                .setCondition('Interface_Transaction_Name__c IN :interfaceTransactionNames')
                .toSOQL()
        );
        return result;
    }

    /**
     * @description It is used for all active interface transaction configuration records.
     * @return List<Interface_Transaction_Configuration__mdt>
     */
    public List<Interface_Transaction_Configuration__mdt> selectAllActiveInterfaceTransactionCongis() {
        List<Interface_Transaction_Configuration__mdt> result = Database.query(
            newQueryFactory().setCondition('Is_Active__c = true').toSOQL()
        );
        return result;
    }

    /**
     * @description It is used for getting the instance on basis of the passed developer name.
     * @param developerName
     * @return Interface_Transaction_Configuration__mdt
     */
    public Interface_Transaction_Configuration__mdt getInstanceValue(String developerName) {
        return Interface_Transaction_Configuration__mdt.getInstance(developerName);
    }
}