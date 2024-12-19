/**
 * @author DoorDash
 * @date   07/20/2022
 * @description LEM-2362 This is the service class for OpportunityContactRole related logic
 */
public inherited sharing class OpportunityContactRoleService {
    static final string CONTRACT_SIGNATORY_ROLE = 'Contract Signatory';
    /**
     * @description Constructor to perform before update processing
     * @param idOpportunityMap
     */
    public static void stampPrimaryQuoteOnOppContactRole(Map<Id, Opportunity> idOpportunityMap) {
        service().stampPrimaryQuoteOnOppContactRole(idOpportunityMap);
    }

    /**
     * @description Update the Contract Signatory Exists flag on related quotes
     * @param contactRolesToSync
     */
    public static void updateRelatedQuotesContractSignatoryExists(
        List<OpportunityContactRole> contactRolesToSync
    ) {
        service().updateRelatedQuotesContractSignatoryExists(contactRolesToSync);
    }

    /**
     * @description updates the contract signatory exists flag
     * @param approvedQuoteIds quote ids to update
     */
    public static void updateContractSignatoryExists(Set<Id> approvedQuoteIds) {
        service().updateContractSignatoryExists(approvedQuoteIds);
    }

    /**
     * @description updates the 'Has Signed Contract' on Contract Signatory Contact Role
     * @param opportunityIds Map
     */
     public static void updateContractSignatoryContactRole(Map<Id, Opportunity> opportunityIds) {
        service().updateContractSignatoryContactRole(opportunityIds);
    }



    private static IOpportunityContactRoleService service() {
        return (IOpportunityContactRoleService) Application.Service.newInstance(
            IOpportunityContactRoleService.class
        );
    }

    /**
     * @description It is used to create OCR Record.
     * @param opportunityIdToContactId
     * @param isPrimary
     */
    public static void createOCR(Map<Id, Id> opportunityIdToContactId, Boolean isPrimary) {
        service().createOCR(opportunityIdToContactId,isPrimary);
    }
}