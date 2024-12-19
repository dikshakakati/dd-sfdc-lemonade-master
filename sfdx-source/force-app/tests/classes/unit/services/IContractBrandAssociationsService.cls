/**
 * @author Gaurav Bisht
 * @date 03/18/2024
 * @description Interface to add ContractBrandAssociationsService class methods
 */
public interface IContractBrandAssociationsService {

    /**
     * @description Creates a new Contract Brand Association record.
     * @param contractId The Id of the Contract.
     * @param brandAsscId The Id of the Brand Association.
     * @return The created Contract Brand Association record.
     */
    Contract_Brand_Association__c createContractBrandAssociaiton(Id contractId, Id brandAsscId);

    /**
     * @description Creates Contract Brand Associations for a given Contract and a set of Brand Association IDs.
     * @param contractId The ID of the Contract for which the relationships need to be created.
     * @param brandAsscIds The set of Brand Association IDs to be associated with the Opportunity.
     * @return A list of Contract_Brand_Association__c records representing the created relationships.
     */
    List<Contract_Brand_Association__c> createContractBrandAssociaitons(Id contractId, Set<Id> brandAsscIds);
}