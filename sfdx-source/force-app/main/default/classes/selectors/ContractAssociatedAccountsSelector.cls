/**
 * @author BizApps
 * @date 05/2023
 * @description Selector Class for ContractAssociatedAccounts Object
 */
public inherited sharing class ContractAssociatedAccountsSelector extends fflib_SObjectSelector implements IContractAssociatedAccountsSelector {
    /**
     * @description default constructor for the Contract_Associated_Accounts__c Selector class
     * @return IContractAssociatedAccountsSelector - interface of IContractAssociatedAccountsSelector
     */
    public static IContractAssociatedAccountsSelector newInstance() {
        return (IContractAssociatedAccountsSelector) Application.Selector.newInstance(
            Contract_Associated_Accounts__c.SObjectType
        );
    }

    /**
     * @description This method is used for getting Object type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Contract_Associated_Accounts__c.SObjectType;
    }

    /**
     * @description This method is for getting the fields on Contract_Associated_Accounts__c object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Contract_Associated_Accounts__c.Id,
            Contract_Associated_Accounts__c.Associated_Account_Ids__c,
            Contract_Associated_Accounts__c.Contract__c,
            Contract_Associated_Accounts__c.Batch_Process_Enabled__c,
            Contract_Associated_Accounts__c.Batch_Process_Status__c,
            Contract_Associated_Accounts__c.Order__c,
            Contract_Associated_Accounts__c.Group__c,
            Contract_Associated_Accounts__c.IsProcessingExistingStores__c,
            Contract_Associated_Accounts__c.Serialized_Entitlements_Data__c
        };
    }

    /**
     * @description This method is used for getting object list based on Id
     * @param idSet
     * @return List<Contract_Associated_Accounts__c>
     */
    public List<Contract_Associated_Accounts__c> selectById(Set<Id> idSet) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id IN: idSet');
        query.selectField('Associated_Account_Ids__c');
        query.selectField('Contract__c');
        query.selectField('Batch_Process_Enabled__c');
        query.selectField('Batch_Process_Status__c');
        query.selectField('Order__c');
        return (List<Contract_Associated_Accounts__c>) Database.query(query.toSOQL());
    }

    /**
     * @description Retrieves all Contract_Associated_Accounts__c for an inputted Contract
     * @param contractId - Id to filter by in Contract__c field
     * @return List<Contract_Associated_Accounts__c>
     **/
    public List<Contract_Associated_Accounts__c> selectByContractId(Id contractId) {
        ignoreCRUD();
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('Contract__c = :contractId')
            .setOrdering('Order__c', fflib_QueryFactory.SortOrder.ASCENDING);

        return (List<Contract_Associated_Accounts__c>) Database.query(query.toSOQL());
    }

    /**
     * @description Retrieves all Contract_Associated_Accounts__c for an inputted Set of Contracts
     * @param contractIds - Set<Id> to filter by in Contract__c field
     * @return List<Contract_Associated_Accounts__c>
     **/
    public List<Contract_Associated_Accounts__c> selectByContractIds(Set<Id> contractIds) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('Contract__c IN :contractIds')
            .setOrdering('Contract__c', fflib_QueryFactory.SortOrder.ASCENDING)
            .setOrdering('Order__c', fflib_QueryFactory.SortOrder.ASCENDING);

        return (List<Contract_Associated_Accounts__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting Contract Associated Accounts records based on the status and process enabled flag
     * @return Database.QueryLocator
     */
    public Database.QueryLocator selectByBatchProcessEnabledAndStatus() {
        String queryCondition = '(Batch_Process_Status__c =\'Not Started\' OR Batch_Process_Status__c = \'Failed\') AND Batch_Process_Enabled__c = true';
        fflib_QueryFactory query = newQueryFactory().setCondition(queryCondition);
        return Database.getQueryLocator(query.toSOQL());
    }

    /**
     * @description This method is used for getting Contract Associated Accounts records based on the status and process enabled flag for an inputted Set of ContractAssociatedAccount IDs
     * @param conAssociatedAccountIds - Set<Id> to filter by Id
     * @return Database.QueryLocator
     */
    public Database.QueryLocator selectByBatchProcessEnabledAndStatusIds(
        Set<Id> conAssociatedAccountIds
    ) {
        String queryCondition = '(Batch_Process_Status__c =\'Not Started\' OR Batch_Process_Status__c = \'Failed\') AND Batch_Process_Enabled__c = true AND Id IN: conAssociatedAccountIds';
        fflib_QueryFactory query = newQueryFactory().setCondition(queryCondition);
        return Database.getQueryLocator(query.toSOQL());
    }
}