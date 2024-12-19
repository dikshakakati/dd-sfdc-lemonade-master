/**
 * @author Deloitte
 * @date 07/03/2024
 * @description Selector interface for Store Details selector.
 */
public interface IStoreDetailsSelector extends fflib_ISObjectSelector {
    /**
     * @description It is for getting the fields on Store_Detail__c.
     * @return List<Schema.SObjectField>
     */
    List<Schema.SObjectField> getSObjectFieldList();

    /**
     * @description This method is used for getting Store Detail records by Id.
     * @param ids
     * @return List<Store_Detail__c>
     */
    List<Store_Detail__c> selectById(Set<Id> ids);
}