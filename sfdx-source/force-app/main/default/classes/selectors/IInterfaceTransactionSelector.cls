/**
 * @author Deloitte
 * @date 22/02/2022
 * @description Interface for InterfaceTransactionSelector
 */
public interface IInterfaceTransactionSelector extends fflib_ISObjectSelector {
    /**
     * @description method to be implemented in child class.
     * @param ids - Intrface Transaction IDs
     * @return List<Interface_Transaction__c> - DML operation result
     */
    List<Interface_Transaction__c> selectById(Set<Id> ids);

    /**
     * @description method to be implemented in child class.
     * @param interfaceId - Interface Id
     * @return List<Interface_Transaction__c> - DML operation result
     */
    List<Interface_Transaction__c> selectByInterface(String interfaceId);

    /**
     * @description Fetches interface transactions for retry process.
     * @return Database.QueryLocator
     */
    Database.QueryLocator queryLocatorReadyToRetry();

    /**
     * @description This method is for getting the Interface Transaction Records
     * based on Record_Id__c field value.
     * @param recordIds
     * @return List<Interface_Transaction__c>
     */
    List<Interface_Transaction__c> selectByOriginRecordIds(Set<String> recordIds);
}