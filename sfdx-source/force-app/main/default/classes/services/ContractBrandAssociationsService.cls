/**
 * @author Gaurav Bisht
 * @date 03/18/2024
 * @description sevice class to add Contract Brand Relations Logic
 */
public with sharing class ContractBrandAssociationsService {

    /**
     * @description Creates a new Opportunity Brand Relationship record.
     * @param contractId The Id of the Contract.
     * @param brandAsscId The Id of the Brand Association.
     * @return The newly created Contract Brand Association record.
     */
    public static Contract_Brand_Association__c  createContractBrandAssociaiton(Id contractId, Id brandAsscId){
        return service().createContractBrandAssociaiton(contractId, brandAsscId);
    }

    /**
     * @description Creates Contract Brand Association for a given Contract and a set of Brand Association IDs.
     * @param contractId The ID of the Contract for which the Brand Relationships are to be created.
     * @param brandAsscIds The set of Brand Association IDs to be associated with the Contract.
     * @return A list of Contract_Brand_Association__c records representing the created relationships.
     */
    public static List<Contract_Brand_Association__c > createContractBrandAssociaitons(Id contractId, Set<Id> brandAsscIds){
        return service().createContractBrandAssociaitons(contractId, brandAsscIds);
    }

    /**
     * @description This method is used to create an instance of ContractBrandAssociationsService class.
     * @return IContractBrandAssociationsService - return instance of ContractBrandAssociationsServiceImpl
     */
    private static IContractBrandAssociationsService service() {
        return (IContractBrandAssociationsService) Application.SERVICE.newInstance(IContractBrandAssociationsService.class);
    }
}