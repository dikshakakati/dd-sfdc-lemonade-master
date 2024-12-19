/**
 * @author Deloitte
 * @date 03/24/2023
 * @description Selector class for Contract Brand Association object.
 */
public inherited sharing class ContractBrandAssociationsSelector extends fflib_SObjectSelector implements IContractBrandAssociationsSelector {
    /**
     * @description default constructor for the Contract Brand Association Selector class
     * @return IContractBrandAssociationsSelector - interface of IContractBrandAssociationsSelector
     */
    public static IContractBrandAssociationsSelector newInstance() {
        return (IContractBrandAssociationsSelector) Application.Selector.newInstance(
            Contract_Brand_Association__c.SObjectType
        );
    }

    /**
     * @description This method is for getting the fields on Contract Brand Association object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Contract_Brand_Association__c.Id,
            Contract_Brand_Association__c.Brand__c,
            Contract_Brand_Association__c.Brand_Id__c,
            Contract_Brand_Association__c.Contract__c,
            Contract_Brand_Association__c.Status__c
        };
    }

    /**
     * @description This method is used for getting Object type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Contract_Brand_Association__c.SObjectType;
    }

    /**
     * @description This method is used for getting records by id.
     * @param contractBrandAssociationIds
     * @return List<Contract_Brand_Association__c>
     */
    public List<Contract_Brand_Association__c> selectById(Set<Id> contractBrandAssociationIds) {
        return (List<Contract_Brand_Association__c>) selectSObjectsById(
            contractBrandAssociationIds
        );
    }

    /**
     * @description This method is used for getting records by id.
     * @param contractIds
     * @return List<Contract_Brand_Association__c>
     */
    public List<Contract_Brand_Association__c> selectByContracts(Set<String> contractIds) {
        fflib_QueryFactory associationsQuery = newQueryFactory()
            .selectField('Brand__r.Name')
            .selectField('Brand__r.Id')
            .setCondition('Contract__c IN :contractIds')
            .setOrdering('Brand__r.Name', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Contract_Brand_Association__c>) Database.query(associationsQuery.toSOQL());
    }

     /**
     * @description LEM-12963 Retrieves a list of Contract_Brand_Association__c records based on the provided contract Id and Brand Id.
     * @param contractId The Id of the contract.
     * @param brandAsscIds The Id of the Brand .
     * @return A list of Contract_Brand_Association__c records that match the given contract Id and Brand Association Id.
     */
    public List<Contract_Brand_Association__c> selectByContractAndBrandAsscs(Id contractId, Set<Id> brandAsscIds) {
        return (List<Contract_Brand_Association__c>) Database.query(
            newQueryFactory()
                .setCondition('Contract__c  = :contractId AND Brand__c IN :brandAsscIds')
                .toSOQL()
        );
    }
}