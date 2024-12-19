/**
 * @author DoorDash
 * @date 07-20-2022
 * @description Interface for OpportunityContactRole class.
 */
public interface IOpportunityContactRoleService {

    /**
    * @description Stamp PrimaryQuote on Opportunity Contact Role
    * @param idOpportunityMap
    */
   void stampPrimaryQuoteOnOppContactRole (Map<Id, Opportunity> idOpportunityMap);

   /**
    * @description Update the Contract Signatory Exists flag on related quotes
    * @param contactRolesToSync
    */
   void updateRelatedQuotesContractSignatoryExists(
       List<OpportunityContactRole> contactRolesToSync
   );

   /**
    * @description updates the contract signatory exists flag
    * @param approvedQuoteIds quote ids to update
    */
   void updateContractSignatoryExists(Set<Id> approvedQuoteIds);
   /**
    * @description updates the 'Has Signed Contract' on Contract Signatory Contact Role
    * @param opportunityIds Map
    */
   void updateContractSignatoryContactRole(Map<Id, Opportunity> opportunityIds);

   /**
     * @description It is used to create OCR Record.
     * @param opportunityIdToContactId
     * @param isPrimary
     */
    void createOCR(Map<Id, Id> opportunityIdToContactId, Boolean isPrimary);
}