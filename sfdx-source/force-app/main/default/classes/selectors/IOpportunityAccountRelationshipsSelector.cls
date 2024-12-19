/**
 * @author Deloitte
 * @date 06/06/2022
 * @description Selector Interface for Opportunity Account Relationship Object
 */
public interface IOpportunityAccountRelationshipsSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is used to fetch all Opportunity Account Relationship records filtered by Opportunity Ids.
     * @param parentOpportunityIds
     * @return List<Opportunity_Account_Relationship__c>
     */
    List<Opportunity_Account_Relationship__c> fetchRelationshipsByParentOpportunities(
        Set<String> parentOpportunityIds
    );
}