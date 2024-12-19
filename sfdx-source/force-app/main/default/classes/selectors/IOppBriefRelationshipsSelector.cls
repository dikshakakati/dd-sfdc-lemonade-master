/**
 * @author ATG
 * @date 10/24/2023
 * @description Interface for Opportunity Brief Relationship selector.
 */
public interface IOppBriefRelationshipsSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is used for querying all Opportunity Brief Relationships
     * provided set of opportunity Ids.
     * @param opportunityIds
     * @return List<Opportunity_Brief_Relationship__c>
     */
    List<Opportunity_Brief_Relationship__c> selectByOpportunities(Set<Id> opportunityIds);
}