/**
 * @author Deloitte
 * @date 11/30/2022
 * @description Interface to add Selector class methods
 */
public interface IBriefsSelector extends fflib_ISObjectSelector {
    /**
     * @description This method id for getting object type
     * @param briefIds
     * @return List of Briefs
     */
    List<Brief__c> selectById(Set<Id> briefIds);

    /**
     * @description This method is used for fetching Briefs by parent Account and related Campaigns.
     * @param accountIds
     * @return List<Brief__c>
     */
    List<Brief__c> selectByAccountIds(Set<Id> accountIds);

    /**
     * @description This method is used for querying all Briefs with Quote Brief Relationships
     * related to Quotes associated with provided set of opportunity Ids.
     * @param opportunityIds
     * @return List<Brief__c>
     */
    List<Brief__c> selectByOpportunities(Set<Id> opportunityIds);

    /**
     * @description This method is used for getting Sobject type Id
     * @param briefIds
     * @return List<Brief__c>
     */
    List<Brief__c> selectByIdIncludingAccountId(Set<Id> briefIds);
    /**
     * @description This method is used for querying all Briefs with Opportunity Brief Relationships
     * provided set of opportunity Ids.
     * @param opportunityIds
     * @return List<Brief__c>
     */
    List<Brief__c> selectByOpportunityBriefRelationship(Set<Id> opportunityIds);

    /**
     * @description This method querys briefs with their primary vertical field
     * @param briefIds
     * @return List<Brief__c>
     */
    List <Brief__c> selectBriefWithPrimaryVertical (Set<Id> briefIds);

}