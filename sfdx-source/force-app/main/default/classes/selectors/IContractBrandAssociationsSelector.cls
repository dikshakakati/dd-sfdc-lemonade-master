/**
 * @author Deloitte
 * @date 03/24/2023
 * @description Interface to add selector methods
 */
public interface IContractBrandAssociationsSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is used for getting records by id.
     * @param contractBrandAssociationIds
     * @return List<Contract_Brand_Association__c>
     */
    List<Contract_Brand_Association__c> selectById(Set<Id> contractBrandAssociationIds);

    /**
     * @description This method is used for getting records by id.
     * @param contractIds
     * @return List<Contract_Brand_Association__c>
     */
    List<Contract_Brand_Association__c> selectByContracts(Set<String> contractIds);

    /**
     * @description Retrieves a list of Contract_Brand_Association__c records based on the provided Contract Id and Brand Association Id.
     * @param contractId The Id of the Contract.
     * @param brandAsscIds The Id of the Brand Association.
     * @return A list of Contract_Brand_Association__c records that match the given Contract Id and Brand Association Id.
     */
    List<Contract_Brand_Association__c> selectByContractAndBrandAsscs(Id contractId, Set<Id> brandAsscIds);
}