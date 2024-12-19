/**
 * @author Deloitte
 * @date 22/02/2022
 * @description Selector Class for Interface Object
 */
public inherited sharing class InterfaceSelector extends fflib_SObjectSelector implements IInterfaceSelector {
    /**
     * @description New instance method to call application selector
     * @param Interface_c.SObjectType - Interface_Transaction__c object type
     * @return IInterfaceSelector - interface of IInterfaceSelector
     */
    public static IInterfaceSelector newInstance() {
        return (IInterfaceSelector) Application.Selector.newInstance(Interface__c.SObjectType);
    }

    /**
     * @description This method is for getting the fields on account object
     * @return Interface object fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Interface__c.Id,
            Interface__c.Class_Interface_Name__c,
            Interface__c.Enable_Retry__c,
            Interface__c.Enable_Logging__c,
            Interface__c.Retry_Limit__c
        };
    }

    /**
     * @description This method is for getting object type
     * @return Interface__c - Object Type
     */
    public Schema.SObjectType getSObjectType() {
        return Interface__c.SObjectType;
    }

    /**
     * @description This method is for getting the Interface Records based on id
     * @param ids - Interface Recods ids
     * @return List<Interface__c> - DML operation result
     */
    public List<Interface__c> selectById(Set<Id> ids) {
        return (List<Interface__c>) selectSObjectsById(ids);
    }

    /**
     * @description This method is for getting the Interface Records based on Class Name
     * @param interfaceClassNames - interface Class Names on Interface__c record
     * @return List<Interface__c> - DML operation result
     */
    public List<Interface__c> selectByClassName(List<String> interfaceClassNames) {
        return (Database.query(
            newQueryFactory()
                .setCondition('Class_Interface_Name__c IN :interfaceClassNames')
                .toSOQL()
        ));
    }
}