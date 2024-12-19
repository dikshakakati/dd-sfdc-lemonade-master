/**
 * @author Deloitte
 * @date 22/02/2022
 * @description Interface to add Selector class methods
 */
public interface IInterfaceSelector extends fflib_ISObjectSelector {
    /**
     * @description method to be implemented in child class.
     * @param ids - Interface__c Record Ids
     * @return List<Interface__c> - List of Interface__c
     */
    List<Interface__c> selectById(Set<Id> ids);

    /**
     * @description method to be implemented in child class.
     * @param interfaceClassNames - interface name on Interface__c record
     * @return List<Interface__c> - List of Interface__c
     */
    List<Interface__c> selectByClassName(List<String> interfaceClassNames);
}